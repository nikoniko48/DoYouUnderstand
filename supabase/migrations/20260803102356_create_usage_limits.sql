-- Server-side fair-use cap for Gemini-backed calls (explain/reply/tweak/
-- generate-more-tones/refine-analyze/refine-transform). Keyed by an
-- anonymous `device_id` the client generates and stores in the Keychain
-- (survives app reinstall, unlike UserDefaults) - no user account required.
-- This is the authoritative limit; the client also keeps its own local,
-- UserDefaults-based pre-check purely so well-behaved users get an instant
-- "come back tomorrow" message without a network round trip, but that local
-- check alone was bypassable by reinstalling the app - this table is what
-- actually protects the Gemini budget.

create table if not exists usage_limits (
  device_id text not null,
  day date not null,
  count integer not null default 0,
  primary key (device_id, day)
);

-- Row Level Security is enabled with no policies, so this table is reachable
-- only via the service role key (used server-side by the Edge Function),
-- never directly by the app's anon key.
alter table usage_limits enable row level security;

-- Atomically increments and returns today's count for a device in one
-- round trip, so two concurrent requests can't both read a stale count and
-- slip through the check.
create or replace function increment_usage(p_device_id text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  insert into usage_limits (device_id, day, count)
  values (p_device_id, current_date, 1)
  on conflict (device_id, day)
  do update set count = usage_limits.count + 1
  returning count into new_count;

  return new_count;
end;
$$;

-- Best-effort housekeeping so this table doesn't grow forever - called
-- opportunistically from the Edge Function rather than needing a cron job.
create or replace function prune_old_usage_limits()
returns void
language sql
security definer
set search_path = public
as $$
  delete from usage_limits where day < current_date - interval '7 days';
$$;
