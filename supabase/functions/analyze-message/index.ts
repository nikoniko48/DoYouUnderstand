// analyze-message
//
// Proxies "explain" / "reply" / "replyForTone" / "tweak" / "refineAnalyze" /
// "refineTransform" analysis requests to Gemini so the API key never ships
// inside the iOS app. Every request must include a `deviceId` (an anonymous,
// Keychain-persisted UUID the client generates - see `DeviceIdentifier.swift`)
// which is checked/incremented against the `usage_limits` table (see the
// `create_usage_limits` migration) before any Gemini call - this is the real
// fair-use enforcement, not just the client's own local pre-check.
//
// Deploy:
//   supabase functions deploy analyze-message
// Apply the usage_limits migration once (and after any future schema change):
//   supabase db push
// Set the secret once (never commit the key itself):
//   supabase secrets set GEMINI_API_KEY=your-key-here
// SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are auto-provided to every Edge
// Function by Supabase - no secret to set for those.

const GEMINI_MODEL = "gemini-flash-latest";

const TONES = [
  "Anxious",
  "Condescending",
  "Over-Eager",
  "Passive-Aggressive",
  "Sarcastic",
  "Professional",
  "Assertive",
  "Friendly",
  "Playful",
  "Apologetic",
  "Empathetic",
  "Blunt",
  "Flirty",
  "Diplomatic",
  "Dismissive",
  "Savage",
];

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// If the input includes a screenshot of a multi-message thread, the model
// tends to reply to (or summarize) the whole conversation instead of the
// specific message it was asked about. This rule keeps it focused.
const THREAD_IMAGE_RULE_EXPLAIN =
  `If the user provides an image of a chat or email thread, read the entire conversation to understand ` +
  `the context, relationship, and tone. However, you must analyze the tone specifically of the FINAL ` +
  `message sent by the other person, not the conversation as a whole. Do not summarize the whole exchange.`;

const THREAD_IMAGE_RULE_REPLY =
  `If the user provides an image of a chat or email thread, read the entire conversation to understand ` +
  `the context, relationship, and tone. However, you must generate your reply specifically addressing the ` +
  `FINAL message sent by the other person. Do not reply to the summary of the chat.`;

const explainSchema = {
  type: "object",
  properties: {
    extractedText: { type: "string" },
    tone: { type: "string", enum: TONES },
    toneScore: { type: "integer" },
    said: { type: "string" },
    meant: { type: "string" },
    subtext: { type: "string" },
    eli5: { type: "string" },
  },
  required: ["extractedText", "tone", "toneScore", "said", "meant", "subtext", "eli5"],
};

const replySchema = {
  type: "object",
  properties: {
    extractedText: { type: "string" },
    tone: { type: "string", enum: TONES },
    toneScore: { type: "integer" },
    toneQuote: { type: "string" },
    replies: {
      type: "array",
      items: {
        type: "object",
        properties: {
          tone: { type: "string", enum: TONES },
          text: { type: "string" },
        },
        required: ["tone", "text"],
      },
    },
  },
  required: ["extractedText", "tone", "toneScore", "toneQuote", "replies"],
};

const tweakSchema = {
  type: "object",
  properties: {
    text: { type: "string" },
  },
  required: ["text"],
};

const refineAnalyzeSchema = {
  type: "object",
  properties: {
    tone: { type: "string" },
    colorTone: { type: "string", enum: TONES },
    summary: { type: "string" },
  },
  required: ["tone", "colorTone", "summary"],
};

// "Refine" is about the user's OWN outgoing draft, not a message they
// received, so its user-facing tone tag is a short freeform label (e.g.
// "Defensive & Hesitant") rather than being constrained to the fixed
// `TONES` list used for Explain/Reply. `colorTone` is a second, separate
// field solely so the client can pick a real color for the card (reusing
// the same 16-tone palette) without constraining the freeform label itself.
const REFINE_ACTIONS: Record<string, string> = {
  fixGrammar:
    "Fix all typos, punctuation, and grammatical mistakes in this draft. Preserve the exact wording, meaning, " +
    "and tone - do not rephrase or add/remove content beyond correcting mistakes.",
  checkClarity:
    "Rewrite this draft so it makes logical sense and is easy to follow, fixing any confusing, ambiguous, or " +
    "contradictory phrasing, while keeping the same overall intent and tone.",
  shorten:
    "Rewrite this draft to be more concise and punchy, cutting unnecessary words while preserving the core " +
    "message and tone.",
  lengthen:
    "Rewrite this draft to be noticeably longer - it must have meaningfully more words than the original. Keep " +
    "the exact same core message, meaning, and tone; do not introduce new topics or claims. Add length only by " +
    "elaborating on what's already there (more detail, fuller phrasing, additional supporting words), never by " +
    "changing what it says.",
};

function messageBlock(text: string): string {
  return text.trim().length > 0
    ? `Message: """${text}"""`
    : `The message was not typed as text - it is provided as an image below. Read the message directly ` +
      `from the screenshot.`;
}

// Every mode that can take an image needs to hand back the plain-text content
// of the message, since the caller may not have typed anything themselves
// (and we don't want to re-upload the image just to reuse the text later).
const EXTRACTED_TEXT_INSTRUCTION =
  `Always populate "extractedText" with the core message content, exactly as a plain-text version of it: ` +
  `if the message text was provided above, echo it back verbatim; if no text was provided and the message ` +
  `came from an image instead, transcribe the core message text directly from the image (just the message ` +
  `itself, not the whole thread/UI chrome around it).`;

function buildExplainPrompt(text: string): string {
  return `You are analyzing a message someone received so they can understand its real tone and subtext.
${messageBlock(text)}

Identify the single dominant tone (one of: ${TONES.join(", ")}), a confidence score 0-100 for that tone,
what was literally said, what the sender actually meant, the unspoken subtext, and a one-sentence
explain-like-I'm-5 summary.

${EXTRACTED_TEXT_INSTRUCTION}

${THREAD_IMAGE_RULE_EXPLAIN}`;
}

function buildReplyPrompt(text: string, tones: string[]): string {
  const base = `You are drafting reply options to a message someone received.
${messageBlock(text)}

First identify the single dominant tone of the ORIGINAL message (one of: ${TONES.join(", ")}), a confidence
score 0-100, and the exact quoted phrase from the original message that best reveals that tone.`;

  const repliesInstruction =
    `Then draft exactly ${tones.length} ready-to-send reply options, one for EACH of the following tones ` +
    `(in this exact order, one entry per tone, no duplicates, no omissions): ${tones.join(", ")}.`;

  return `${base}\n${repliesInstruction}\n\n${EXTRACTED_TEXT_INSTRUCTION}\n\n${THREAD_IMAGE_RULE_REPLY}`;
}

// Used for on-demand "generate just this one tone" taps after the initial
// batch - the client already has the plain-text message from that earlier
// call, so this skips re-analyzing the original tone and just drafts the
// one new reply, same lightweight shape as buildTweakPrompt.
function buildReplyForTonePrompt(text: string, tone: string): string {
  return `You are drafting a reply to a message someone received.
Message: """${text}"""

Draft exactly one ready-to-send reply option in a ${tone} tone that responds to this message.

Return only the reply text - no preamble, no quotes, no explanation.`;
}

function buildTweakPrompt(replyText: string, tone: string, instruction: string): string {
  return `You previously drafted this reply in a ${tone} tone:
"""${replyText}"""

${instruction}

Rewrite the reply accordingly. Keep it a complete, ready-to-send message addressing the same point as the
original reply. Return only the rewritten reply text.`;
}

function buildRefineAnalyzePrompt(text: string): string {
  return `You are analyzing a draft message someone is ABOUT TO SEND (not one they received), to help them ` +
    `understand how it will likely come across before they send it.
Draft: """${text}"""

Identify the detected tone/vibe of this draft in 2-4 words (e.g. "Defensive & Hesitant", "Overly Formal", ` +
    `"Warm & Casual") - be specific and insightful rather than picking from a fixed list. Call this "tone".
Also classify that same vibe into whichever single one of these fixed categories is the closest match ` +
    `(this is just for picking a display color, so approximate is fine): ${TONES.join(", ")}. Call this "colorTone".
Then write a single, concise sentence describing how the reader will likely perceive this message. Call this "summary".

You MUST write both "tone" and "summary" in the exact same language the draft itself is written in - "colorTone" ` +
    `must always stay one of the exact English category names listed above, regardless of the draft's language.`;
}

function buildRefineTransformPrompt(text: string, action: string): string {
  const instruction = REFINE_ACTIONS[action];
  return `You are helping someone refine a draft message before they send it.
Draft: """${text}"""

${instruction}

Return only the rewritten message text - no preamble, no quotes, no explanation. You MUST write it in the ` +
    `exact same language as the original draft above.`;
}

const DAILY_USAGE_LIMIT = 30;

// The authoritative fair-use cap - keyed by an anonymous `deviceId` the
// client generates once and stores in the Keychain (survives app reinstall,
// unlike the client's own UserDefaults-based pre-check, which is only a fast
// local UX shortcut, not real enforcement). Uses the service role key so it
// bypasses this table's RLS (which has no policies, so the anon key alone
// could never reach it) - increments atomically in one round trip via the
// `increment_usage` Postgres function so concurrent requests can't both
// slip through on a stale read.
async function checkAndIncrementUsage(deviceId: string): Promise<number> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Missing Supabase service credentials");
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/increment_usage`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": serviceRoleKey,
      "Authorization": `Bearer ${serviceRoleKey}`,
    },
    body: JSON.stringify({ p_device_id: deviceId }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Usage check failed: ${errorBody}`);
  }

  return await response.json() as number;
}

// Appended to the "reply" and "replyForTone" prompts when the client sent a
// concrete target language. "Auto-detect" (or no value at all) means match
// whatever language the original message is already in, which is what the
// model does by default anyway, so it needs no extra instruction.
function languageDirective(targetLanguage: unknown): string {
  if (typeof targetLanguage !== "string" || targetLanguage.length === 0 || targetLanguage === "Auto-detect") {
    return "";
  }
  return ` You MUST write the generated reply strictly in ${targetLanguage}, regardless of the language of ` +
    `the original incoming text.`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      throw new Error("Missing GEMINI_API_KEY secret");
    }

    const { mode, text, images, tones, tone, instruction, targetLanguage, action, deviceId, debugBypassToken } =
      await req.json();
    const validModes = ["explain", "reply", "replyForTone", "tweak", "refineAnalyze", "refineTransform"];
    if (!validModes.includes(mode)) {
      throw new Error(`mode must be one of: ${validModes.join(", ")}`);
    }
    if (typeof deviceId !== "string" || deviceId.length === 0) {
      throw new Error("deviceId is required");
    }

    // Lets local `#if DEBUG` builds exhaust their own budget testing without
    // ever tripping the fair-use cap - `DEBUG_BYPASS_SECRET` is unset (so
    // this never matches) unless explicitly configured. Never sent by a
    // Release/TestFlight/App Store build (see `DebugBypass` client-side).
    const debugSecret = Deno.env.get("DEBUG_BYPASS_SECRET");
    const isDebugBypass = typeof debugBypassToken === "string" && debugSecret !== undefined &&
      debugBypassToken === debugSecret;

    if (!isDebugBypass) {
      const usageCount = await checkAndIncrementUsage(deviceId);
      if (usageCount > DAILY_USAGE_LIMIT) {
        return new Response(
          JSON.stringify({ error: "daily_limit_reached" }),
          { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    const messageText = typeof text === "string" ? text : "";
    const imageList = (images ?? []) as string[];
    const noImageModes = mode === "tweak" || mode === "replyForTone" || mode === "refineAnalyze" ||
      mode === "refineTransform";

    if (noImageModes && messageText.trim().length === 0) {
      throw new Error(`text is required for ${mode} mode`);
    }
    if (!noImageModes && messageText.trim().length === 0 && imageList.length === 0) {
      throw new Error("Provide text or at least one image");
    }

    let promptText: string;
    let schema: Record<string, unknown>;

    switch (mode) {
      case "explain":
        promptText = buildExplainPrompt(messageText);
        schema = explainSchema;
        break;
      case "reply": {
        const toneList = (tones ?? []) as string[];
        if (toneList.length === 0) {
          throw new Error("tones is required and must be non-empty for reply mode");
        }
        promptText = buildReplyPrompt(messageText, toneList) + languageDirective(targetLanguage);
        schema = replySchema;
        break;
      }
      case "replyForTone": {
        if (!tone || typeof tone !== "string") {
          throw new Error("tone is required for replyForTone mode");
        }
        promptText = buildReplyForTonePrompt(messageText, tone) + languageDirective(targetLanguage);
        schema = tweakSchema;
        break;
      }
      case "tweak": {
        if (!tone || typeof tone !== "string" || !instruction || typeof instruction !== "string") {
          throw new Error("tone and instruction are required for tweak mode");
        }
        promptText = buildTweakPrompt(messageText, tone, instruction);
        schema = tweakSchema;
        break;
      }
      case "refineAnalyze": {
        promptText = buildRefineAnalyzePrompt(messageText);
        schema = refineAnalyzeSchema;
        break;
      }
      case "refineTransform": {
        if (!action || typeof action !== "string" || !(action in REFINE_ACTIONS)) {
          throw new Error(`action is required for refineTransform mode and must be one of: ${Object.keys(REFINE_ACTIONS).join(", ")}`);
        }
        promptText = buildRefineTransformPrompt(messageText, action);
        schema = tweakSchema;
        break;
      }
    }

    const parts: Record<string, unknown>[] = [{ text: promptText }];
    if (!noImageModes) {
      for (const base64 of imageList) {
        parts.push({ inline_data: { mime_type: "image/jpeg", data: base64 } });
      }
    }

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify({
          contents: [{ role: "user", parts }],
          generationConfig: {
            responseMimeType: "application/json",
            responseSchema: schema,
          },
        }),
      },
    );

    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      throw new Error(`Gemini request failed: ${errorBody}`);
    }

    const geminiJson = await geminiResponse.json();
    const rawText = geminiJson.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!rawText) {
      throw new Error("Gemini returned no content");
    }

    return new Response(rawText, {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
