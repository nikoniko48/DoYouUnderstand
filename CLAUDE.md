# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

DoYouUnderstand is a native iOS SwiftUI app (Swift 5.0, iOS 18.2 deployment target) that analyzes a pasted/photographed message and either explains its subtext/tone or drafts a reply in one of 15 tones. New users first go through an 11-step onboarding funnel (name, age, gender, app theme pick, a "which message triggers you" quiz, a fake analysis/loading screen, a stats screen, a press-and-hold gesture step, a privacy screen, and a paywall) before landing on the Dashboard. Analysis is powered live by Gemini through a Supabase Edge Function (`supabase/functions/analyze-message`) so the Gemini API key never ships inside the app; history is persisted on-device as JSON. There is a single Xcode project with one app target and two test targets.

## Communication Protocol (User Alerts)

I am not always looking at the screen. You must notify me of your status via the terminal using the `ntfy.sh` curl command.

1. When a task is 100% complete:
Run this exact terminal command to let me know I can come back:
`curl -d "✅ Claude: Task complete! Come check it." ntfy.sh/dyu_claude_alerts_4848`

2. When you need my input, permission, or are stuck:
If you encounter an error you cannot fix, need me to make a decision, or need permission to run a command, run this command FIRST before waiting for my reply in the chat:
`curl -d "⚠️ Claude: I am stuck or need your permission. Please check the chat." ntfy.sh/dyu_claude_alerts_4848`

## Commands

Build (Debug, simulator):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

CRITICAL TESTING PROTOCOL:
UI Tests (`DoYouUnderstandUITests`) take ~3+ minutes each and severely slow down the feedback loop.
- NEVER run UI tests automatically while working on tasks.
- ONLY run Unit tests to verify standard code logic.
- Run UI tests ONLY if the user explicitly states: "Run the UI tests."

Run ONLY Unit Tests (Fast - Use this by default):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DoYouUnderstandTests test
```

Run a single test (Swift Testing framework, not XCTest):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DoYouUnderstandTests/DoYouUnderstandTests/example test
```

Run UI Tests (SLOW - Only run if explicitly asked by user):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DoYouUnderstandUITests test
```

There is no CLI linter/formatter configured in the repo (no SwiftLint config present). List available simulator destinations with:
```bash
xcodebuild -showdestinations -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand
```

Unit tests (`DoYouUnderstandTests`) use `import Testing` / `@Test` / `#expect(...)` (Swift Testing), not XCTest. UI tests (`DoYouUnderstandUITests`) use standard `XCTest`/`XCUIApplication`.

## Architecture

Most features follow the same four-file MVVM-ish pattern under `Features/<FeatureName>/` (Onboarding is the one exception — see below):

- **`<Feature>StateModel.swift`** — an `@Observable final class StateModel` nested as an extension of the ViewModel (`extension DashboardViewModel { @Observable final class StateModel: StateModelProtocol { ... } }`), holding the plain data the view renders.
- **`<Feature>ViewModel.swift`** — `@Observable final class` conforming to `StateViewModelProtocol` (`Shared/State/StateViewModel.swift`). Owns `stateModel`, `state: ViewState<StateModel>`, an `Actions` struct of closures the view calls into, and an `Output` enum for events that bubble up to navigation. Business logic that mutates `stateModel` lives in a `// MARK: - Functions -` extension; wiring closures lives in a `// MARK: - Actions -` extension via `setActions()`.
- **`<Feature>Screen.swift`** (under `Views/` for Dashboard) — a `View` that owns `@State var viewModel`, renders `StateScreen(state: viewModel.state) { stateModel in ... }`, and a nested `ContentView` that takes `stateModel` + `actions` as plain values (keeps previews/content stateless and easy to preview in isolation).
- **Mocks** — only `FAQ` (`Models/FAQItem+Mocks.swift`) and `Input` (`PickedImage+Mocks.swift`) still have per-feature static mock data gated behind a `useMocks: Bool` flag on the ViewModel. `Dashboard`/`Explanation`/`Reply` no longer take a `useMocks` flag at all — they're driven live by `HistoryServiceProtocol` (see History below) and the real Gemini-backed service. `Settings` and `Onboarding` still accept `useMocks: Bool` in their initializer for interface consistency, but neither currently branches on it (there's nothing left to mock). `Input`'s `useMocks` only gates a Simulator-only fallback for capturing a photo when no camera hardware is present — the actual analysis call is always live.

Shared infrastructure lives in `Shared/`:

- **`Shared/State/`** — the `ViewState<StateModel>` enum (`.loading` / `.loaded` / `.error`), `StateModelProtocol`, `StateViewModelProtocol`, and `StateScreen<StateModel, Content>` (the generic loading/error/content switcher every screen wraps its content in).
- **`Shared/Navigation/NavigationManager.swift`** — a single `@Observable` router owning a `NavigationPath`. Screens never navigate directly; they call `output(...)` closures. `ContentView.swift` is the single `NavigationStack` root: each `Screen` is constructed with an `output` closure that forwards into `router.handle(.featureName(output))`, and `NavigationManager` translates each feature's `Output` enum into `navigate(to: Route)` / `popBack()` calls. `Route` is the app-wide `Hashable` enum of destinations. To add a new screen: add a `Route` case, add a `FlowEvent` case + `handle*` function in `NavigationManager`, and add the `navigationDestination` case in `ContentView`.
- **`Shared/Theme/AppTheme.swift`** — the only source of colors/fonts (`Theme.Colors.Main/Text/Tone`, `Theme.Typography`). Colors are backed by named entries in `Assets.xcassets`. `Theme.Colors.Tone` now has 15 dedicated color constants, one per `Tone` case. Typography is built from two custom variable fonts (not system fonts): `Theme.Typography.spaceGrotesk(size:weight:)` for titles/headlines/big numbers/buttons, and `Theme.Typography.inter(size:weight:)` for body copy/labels — the named tokens (`heroTitle`, `bodyText`, etc.) are just pre-built calls to those two helpers. Always reference `Theme.*` rather than hardcoding `Color(...)`/`Font.custom(...)` in views.
- **`Shared/Fonts/`** — the two bundled variable font files (`Inter-VariableFont_opsz,wght.ttf`, `SpaceGrotesk-VariableFont_wght.ttf`) plus their OFL licenses, and `AppFonts.swift`, whose `AppFonts.registerAll()` is called once from `DoYouUnderstandApp.init()` to register them with CoreText (`CTFontManagerRegisterFontsForURL`) at launch.
- **`Shared/StaticData/AppLayout.swift`** — shared spacing/sizing constants (`StaticData.Layout.*` and `CGFloat.space0...space32`). Use these instead of magic numbers in view padding/frames. (`AppStrings.swift` only has a handful of Dashboard strings — most feature copy is written inline in the view files.)
- **`Shared/Services/GeminiService.swift`** — live, not a stub: an `enum` of `static func`s (`explain`, `reply`, `tweak`) that POST JSON to the `analyze-message` Supabase Edge Function and decode the response into feature `Payload` types, converting tone strings to `Tone(rawValue:)` (throws `ServiceError.invalidResponse` if the server ever returns a tone string that doesn't match a case in `Shared/Models/Tone.swift`, so the two must stay in sync). **`Shared/Services/SupabaseManager.swift`** holds the project URL and anon key and builds Edge Function URLs. The actual prompt-building/Gemini-calling logic lives server-side in `supabase/functions/analyze-message/index.ts` (Deno) — deployed independently via `supabase functions deploy analyze-message`; editing that file in the repo does **not** update the live function until it's redeployed. The Gemini API key is only ever set as a Supabase secret, never committed.
- **`Shared/History/`** — `HistoryServiceProtocol` (`fetchAll`/`fetch(id:)`/`save`/`delete`) has two implementations: `LocalHistoryService` (the default, real on-device JSON persistence under Application Support — no network) and `MockHistoryService` (in-memory seed data, used for SwiftUI Previews). `HistoryServiceProvider.shared` is the single switch between them — flip the one commented-out line in that file to swap the whole app onto mock data.
- **`Shared/Models/`** — cross-feature domain enums: `AnalysisType` (`.explain` / `.reply`), `Tone` (15 cases — see below), `AppThemeChoice` (`.light`/`.dark`/`.terminal`, picked during onboarding, persisted via the `selectedAppTheme` `@AppStorage` key, applied app-wide through `.preferredColorScheme` in `ContentView`; `.terminal` has no real palette yet so it intentionally falls back to the system appearance), and `TonePaletteChoice` (`.classic`/`.pastel`/`.neon`/`.mono` — a separate, purely decorative onboarding "pick a color palette" preview that persists a preference but does not yet re-skin `Theme.Colors.Tone` app-wide).

`Tone` (`Shared/Models/Tone.swift`) has grown to **15 cases**: `anxious`, `condescending`, `overEager`, `passiveAggressive`, `sarcastic`, `professional`, `assertive`, `friendly`, `playful`, `apologetic`, `empathetic`, `blunt`, `flirty`, `diplomatic`, `dismissive`. Every property (`color`, `emoji`, `replyTitle`, `tweakLowLabel`, `tweakHighLabel`) is an exhaustive `switch` over `self`, so the compiler forces you to fill in all five for any new case. The Reply screen now requests **5** reply options up front (was 3) and 5 more per "Generate More Tones" tap; that count is defined server-side in `buildReplyPrompt` in the Edge Function, not in Swift.

### Onboarding (the exception to the four-file pattern)

`Features/Onboarding/` is a single 11-step, forward-only funnel (`OnboardingViewModel.StateModel.Step`: `greeting → name → age → theme → intro → triggerMessage → processing → stats → tactileHold → privacy → finisher`) with no back navigation. It outgrew the standard `StateModel`/`ViewModel`/`Screen` split into several files:

- `OnboardingStateModel.swift` / `OnboardingViewModel.swift` — the usual state/view-model pair, plus per-step option enums (`GenderChoice`, `TriggerMessage`, `PricingPlan`).
- `OnboardingScreen.swift` — the shell: progress header, footer (Continue/auto-advance), and the `switch` that routes to each step's view.
- `OnboardingScreen+IntroSteps.swift`, `+QuizSteps.swift`, `+ClosingSteps.swift`, `+Components.swift`, `+Animations.swift` — the actual step views and shared onboarding-only UI pieces (bar-chart counters, message bubbles, the press-and-hold "tactile" gesture, the `.onboardingReveal(delay:)` fade/slide-in modifier), grouped by where they sit in the funnel rather than one file per step.

`ContentView` decides once per app launch whether to start on onboarding (`isShowingOnboarding`, initialized from a `#if DEBUG` `debugAlwaysShowOnboarding` override if set, otherwise from the persisted `hasSeenOnboarding` `@AppStorage` flag) and only flips to the Dashboard when onboarding explicitly finishes — so completing the funnel always moves forward even on a debug build that always starts on onboarding. There's a `#if DEBUG`-only "Skip Onboarding" button on the greeting screen for fast iteration. There's no payment integration yet: the paywall (finisher) step's "Start Free Trial" button just marks onboarding complete.

Features present: `Onboarding`, `Dashboard` (history list + entry point), `Input` (text/photo capture, choose explain vs. reply), `Explanation`, `Reply`, `FAQ`, `Settings`. Dashboard's `HistoryItem.type: AnalysisType` determines whether tapping a history row routes to `.explenation(id)` or `.reply(id)` (note: `Route.explenation` is the existing, intentionally-matched spelling — don't silently "fix" it in isolation, it's used across `NavigationManager`/`ContentView`).
