# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

DoYouUnderstand is a native iOS SwiftUI app (Swift 5.0, iOS 18.2 deployment target) that analyzes a pasted/photographed message and either explains its subtext/tone or drafts a reply in a chosen tone. There is a single Xcode project with one app target and two test targets.

## Commands

Build (Debug, simulator):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Run all tests:
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Run a single test (Swift Testing framework, not XCTest):
```bash
xcodebuild -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DoYouUnderstandTests/DoYouUnderstandTests/example test
```

There is no CLI linter/formatter configured in the repo (no SwiftLint config present). List available simulator destinations with:
```bash
xcodebuild -showdestinations -project DoYouUnderstand.xcodeproj -scheme DoYouUnderstand
```

Unit tests (`DoYouUnderstandTests`) use `import Testing` / `@Test` / `#expect(...)` (Swift Testing), not XCTest. UI tests (`DoYouUnderstandUITests`) use standard `XCTest`/`XCUIApplication`.

## Architecture

Every feature follows the same four-file MVVM-ish pattern under `Features/<FeatureName>/`:

- **`<Feature>StateModel.swift`** — an `@Observable final class StateModel` nested as an extension of the ViewModel (`extension DashboardViewModel { @Observable final class StateModel: StateModelProtocol { ... } }`), holding the plain data the view renders.
- **`<Feature>ViewModel.swift`** — `@Observable final class` conforming to `StateViewModelProtocol` (`Shared/State/StateViewModel.swift`). Owns `stateModel`, `state: ViewState<StateModel>`, an `Actions` struct of closures the view calls into, an `Output` enum for events that bubble up to navigation, and a `useMocks: Bool` flag. Business logic that mutates `stateModel` lives in a `// MARK: - Functions -` extension; wiring closures lives in a `// MARK: - Actions -` extension via `setActions()`.
- **`<Feature>Screen.swift`** (under `Views/` for Dashboard) — a `View` that owns `@State var viewModel`, renders `StateScreen(state: viewModel.state) { stateModel in ... }`, and a nested `ContentView` that takes `stateModel` + `actions` as plain values (keeps previews/content stateless and easy to preview in isolation).
- **`<Feature>Screen+Mocks.swift` / `<Model>+Mocks.swift`** — static mock data (e.g. `HistoryItem.mockList`, `ExplanationViewModel.StateModel.mock(for:)`) used when `useMocks: true` is passed into the ViewModel's initializer. Every ViewModel currently runs with `useMocks: true` — backend integration is not wired up yet (see below).

Shared infrastructure lives in `Shared/`:

- **`Shared/State/`** — the `ViewState<StateModel>` enum (`.loading` / `.loaded` / `.error`), `StateModelProtocol`, `StateViewModelProtocol`, and `StateScreen<StateModel, Content>` (the generic loading/error/content switcher every screen wraps its content in).
- **`Shared/Navigation/NavigationManager.swift`** — a single `@Observable` router owning a `NavigationPath`. Screens never navigate directly; they call `output(...)` closures. `ContentView.swift` is the single `NavigationStack` root: each `Screen` is constructed with an `output` closure that forwards into `router.handle(.featureName(output))`, and `NavigationManager` translates each feature's `Output` enum into `navigate(to: Route)` / `popBack()` calls. `Route` is the app-wide `Hashable` enum of destinations. To add a new screen: add a `Route` case, add a `FlowEvent` case + `handle*` function in `NavigationManager`, and add the `navigationDestination` case in `ContentView`.
- **`Shared/Theme/AppTheme.swift`** — the only source of colors/fonts (`Theme.Colors.Main/Text/Tone`, `Theme.Typography`). Colors are backed by named entries in `Assets.xcassets` (supports light/dark). Always reference `Theme.*` rather than hardcoding `Color(...)`/`Font.system(...)` in views.
- **`Shared/StaticData/AppLayout.swift`** — shared spacing/sizing constants (`StaticData.Layout.*` and `CGFloat.space0...space32`). Use these instead of magic numbers in view padding/frames.
- **`Shared/Services/GeminiService.swift`**, **`Shared/Services/SupabaseManager.swift`** — currently empty stub files. The intended backend is Gemini (analysis/generation) + Supabase (persistence/history), but no networking code exists yet; every `ViewModel.loadData()`/equivalent currently branches on `useMocks` with a `// TODO` in the `else` (live) branch.
- **`Shared/Models/`** — cross-feature domain enums: `AnalysisType` (`.explain` / `.reply`) and `Tone` (maps to `Theme.Colors.Tone.*`, an emoji, and a `replyTitle`).

Features present: `Onboarding`, `Dashboard` (history list + entry point), `Input` (text/photo capture, choose explain vs. reply), `Explanation`, `Reply`. Dashboard's `HistoryItem.type: AnalysisType` determines whether tapping a history row routes to `.explenation(id)` or `.reply(id)` (note: `Route.explenation` is the existing, intentionally-matched spelling — don't silently "fix" it in isolation, it's used across `NavigationManager`/`ContentView`).
