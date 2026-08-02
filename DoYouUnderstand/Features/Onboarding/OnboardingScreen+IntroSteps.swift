//
//  OnboardingScreen+IntroSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

extension OnboardingScreen {

    struct GreetingStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        private static let points: [Feature] = [
            Feature(icon: "magnifyingglass", text: "Decode what any message really means", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "bolt.fill", text: "Get the perfect reply in seconds", toneColor: Theme.Colors.Tone.sarcastic),
            Feature(icon: "lock.fill", text: "No account, no cloud, 100% private", toneColor: Theme.Colors.Tone.anxious)
        ]

        // The "hook" - a passive-aggressive-reading message - followed by
        // its decoded subtext, mirroring exactly what the app itself does
        // with a real message, as the very first thing a new user sees.
        // Computed, not `static let` - see the note on `demoTones` in
        // `OnboardingScreen+ClosingSteps.swift` for why.
        private static var hookText: String { Loc.t("We need to talk.") }
        private static var decodedText: String { Loc.t("I am feeling insecure and need reassurance.") }

        private enum IntroPhase {
            case hidden
            case messageIn
            case decoding
            case subtextRevealed
            case done
        }

        @State private var introPhase: IntroPhase = .hidden
        @State private var isDecodingPulsing = false
        @State private var isMainUIVisible = false

        var body: some View {
            ZStack {
                mainContent
                    .opacity(isMainUIVisible ? 1 : 0)
                    .offset(y: isMainUIVisible ? 0 : 16)
                    .allowsHitTesting(isMainUIVisible)

                introPreview
                    .opacity(introPhase == .hidden || introPhase == .done ? 0 : 1)
                    .scaleEffect(introPhase == .done ? 0.9 : 1)
            }
            .task {
                await playIntro()
            }
        }

        @MainActor
        private func playIntro() async {
            // If this view is somehow recreated after the intro already
            // finished once, skip straight to the settled end state instead
            // of replaying it (and instead of leaving the main UI stuck
            // invisible, which returning early with no other change would
            // otherwise do).
            guard stateModel.isGreetingIntroPlaying else {
                introPhase = .done
                isMainUIVisible = true
                return
            }

            // Phase A (0.0s-1.2s): the incoming message card pops in.
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                introPhase = .messageIn
            }
            try? await Task.sleep(nanoseconds: 1_200_000_000)

            // Phase B (1.2s-2.0s): a "decoding" status badge appears below it.
            withAnimation(.easeInOut(duration: 0.3)) {
                introPhase = .decoding
            }
            try? await Task.sleep(nanoseconds: 800_000_000)

            // Phase C (2.0s-3.8s): the hidden-subtext card expands in.
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                introPhase = .subtextRevealed
            }
            // ...then hold the complete message + subtext pair for ~1.5s
            // (3.8s-5.3s) so the "aha" moment actually registers.
            try? await Task.sleep(nanoseconds: 3_300_000_000)

            // Phase D: fade out / scale down the intro preview, then fade
            // in the real screen behind it.
            withAnimation(.easeIn(duration: 0.4)) {
                introPhase = .done
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
            withAnimation(.easeOut(duration: 0.6)) {
                isMainUIVisible = true
                stateModel.isGreetingIntroPlaying = false
            }
        }

        private var introPreview: some View {
            VStack(alignment: .leading, spacing: .space12) {
                if introPhase != .hidden {
                    IncomingMessageBubble(
                        senderLabel: Loc.t("RECEIVED MESSAGE"),
                        text: Self.hookText,
                        toneColor: Theme.Colors.Tone.passiveAggressive
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
                }

                if introPhase == .decoding || introPhase == .subtextRevealed {
                    decodingBadge
                        .transition(.opacity)
                }

                if introPhase == .subtextRevealed {
                    subtextRevealCard
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.92, anchor: .top)),
                                removal: .opacity
                            )
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        private var decodingBadge: some View {
            HStack(spacing: .space8) {
                BouncingDotsLoader(color: Theme.Colors.Main.accent, dotSize: 5)

                Text("DECODING SUBTEXT...")
                    .font(Theme.Typography.tinyLabel)
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.Main.accent)
            }
            .padding(.horizontal, .space12)
            .padding(.vertical, .space8)
            .background(Theme.Colors.Main.accent.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.Colors.Main.accent.opacity(0.5), lineWidth: 1))
            .shadow(color: Theme.Colors.Main.accent.opacity(isDecodingPulsing ? 0.5 : 0.1), radius: 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    isDecodingPulsing = true
                }
            }
        }

        // Colored/tagged as "Anxious" rather than the neutral app accent -
        // the decoded line itself reads as an anxious/insecure subtext, so
        // matching the card to that tone (the same way a real Explanation
        // result would) makes the reveal feel more alive and previews
        // exactly what the app does with a real message.
        private var subtextRevealCard: some View {
            VStack(alignment: .leading, spacing: .space8) {
                HStack(spacing: .space6) {
                    Image(systemName: "eye.fill")
                    Text("HIDDEN SUBTEXT DETECTED")
                }
                .font(Theme.Typography.badgeLabel)
                .foregroundStyle(Tone.anxious.color)

                Text(String(format: Loc.t("%@ ANXIOUS"), Tone.anxious.emoji))
                    .font(Theme.Typography.tinyLabel.weight(.bold))
                    .foregroundStyle(Tone.anxious.color)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(Tone.anxious.color.opacity(0.18))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Tone.anxious.color.opacity(0.5), lineWidth: 1))

                Text(Self.decodedText)
                    .font(Theme.Typography.onboardingBody.weight(.semibold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.space16)
            .frame(maxWidth: 290, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                        .fill(Tone.anxious.color.opacity(0.18))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                    .stroke(Tone.anxious.color, lineWidth: 2)
            )
        }

        private var mainContent: some View {
            VStack(alignment: .leading, spacing: .space32) {
                Spacer(minLength: .space0)

                VStack(alignment: .leading, spacing: .space16) {
                    Text("STOP GUESSING\nWHAT THEY MEAN.")
                        .font(Theme.Typography.heroTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("DoYouUnderstand decodes the subtext behind any text, DM, or email, and hands you the perfect reply.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Array(Self.points.enumerated()), id: \.element.id) { index, point in
                        FinisherFeatureRow(icon: point.icon, text: point.text, toneColor: point.toneColor)
                    }
                }

                Spacer(minLength: .space0)

#if DEBUG
                Button {
                    actions.onFinish?()
                } label: {
                    Text("Skip Onboarding (Debug)")
                        .font(Theme.Typography.smallBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .underline()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.bottom, .space8)
#endif
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct NameStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        @FocusState private var isNameFieldFocused: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("What should we call you?")
                    .font(Theme.Typography.onboardingTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                TextField(
                    "",
                    text: Binding(
                        get: { stateModel.name },
                        set: { actions.onNameChanged?($0) }
                    ),
                    prompt: Text("Your name")
                        .foregroundStyle(Theme.Colors.Text.muted)
                )
                .focused($isNameFieldFocused)
                .font(Theme.Typography.onboardingBody.weight(.bold))
                .foregroundStyle(Theme.Colors.Text.title)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(.space16)
                .background(Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                )
                .onboardingReveal(delay: 0.12)
            }
            .onAppear {
                // A short delay so the request lands after this step's own
                // slide-in transition settles, instead of fighting it for
                // the keyboard's own show animation.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isNameFieldFocused = true
                }
            }
        }
    }

    struct AgeStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        // Chunked into rows of 2 up front (not a LazyVGrid) - there are only
        // ever 4 fixed options, and a plain VStack/HStack lays out
        // immediately instead of deferring until scrolled into view.
        private static let genderRows: [[OnboardingViewModel.StateModel.GenderChoice]] = {
            stride(from: 0, to: OnboardingViewModel.StateModel.GenderChoice.allCases.count, by: 2).map {
                Array(OnboardingViewModel.StateModel.GenderChoice.allCases[$0..<min($0 + 2, OnboardingViewModel.StateModel.GenderChoice.allCases.count)])
            }
        }()

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space32) {
                    VStack(alignment: .leading, spacing: .space8) {
                        Text("How old are you?")
                            .font(Theme.Typography.onboardingTitle)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text("This helps us tailor tone suggestions and examples to your age group.")
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .onboardingReveal(delay: 0)

                    VStack(spacing: .space24) {
                        Text("\(Int(stateModel.age))")
                            .font(Theme.Typography.spaceGrotesk(size: 72, weight: .black))
                            .foregroundStyle(Theme.Colors.Main.accent)
                            .contentTransition(.numericText())
                            .frame(maxWidth: .infinity)

                        Slider(
                            value: Binding(
                                get: { stateModel.age },
                                set: { actions.onAgeChanged?($0) }
                            ),
                            in: OnboardingViewModel.StateModel.ageRange,
                            step: 1
                        )
                        .tint(Theme.Colors.Main.accent)
                    }
                    .padding(.space24)
                    .background(Theme.Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0.12)

                    VStack(alignment: .leading, spacing: .space16) {
                        VStack(alignment: .leading, spacing: .space8) {
                            Text("What's your gender?")
                                .font(Theme.Typography.onboardingTitle)
                                .foregroundStyle(Theme.Colors.Text.title)

                            Text("Helps us fine-tune reply style. Prefer not to answer? That's a valid choice too.")
                                .font(Theme.Typography.bodyText)
                                .foregroundStyle(Theme.Colors.Text.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(spacing: .space12) {
                            ForEach(Self.genderRows, id: \.self) { row in
                                HStack(spacing: .space12) {
                                    ForEach(row) { gender in
                                        GenderOptionChip(
                                            title: gender.displayName,
                                            isSelected: stateModel.selectedGender == gender
                                        ) {
                                            actions.onSelectGender?(gender)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.24)
                }
            }
            // The vertical ScrollView's default edge-to-edge clipping was
            // slicing a sliver off the selected chip's border on the left
            // and right - there's nothing meaningful to hide off-screen
            // horizontally here, so disabling it is safe.
            .scrollClipDisabled()
        }
    }

    struct GenderOptionChip: View {

        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(Theme.Typography.onboardingBody.weight(.bold))
                    .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .space16)
                    .padding(.horizontal, .space8)
                    .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(
                                isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    struct ThemeStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space32) {
                    VStack(alignment: .leading, spacing: .space16) {
                        VStack(alignment: .leading, spacing: .space8) {
                            Text("Choose your theme.")
                                .font(Theme.Typography.onboardingTitle)
                                .foregroundStyle(Theme.Colors.Text.title)

                            Text("Don't worry about picking wrong. You can always change this later in Settings.")
                                .font(Theme.Typography.bodyText)
                                .foregroundStyle(Theme.Colors.Text.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .onboardingReveal(delay: 0)

                        VStack(spacing: .space12) {
                            ForEach(Array(AppThemeChoice.allCases.enumerated()), id: \.element.id) { index, theme in
                                ThemePreviewCard(
                                    theme: theme,
                                    isSelected: stateModel.selectedTheme == theme
                                ) {
                                    actions.onSelectTheme?(theme)
                                }
                                .onboardingReveal(delay: 0.1 + Double(index) * 0.08)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Tone color palette")
                            .font(Theme.Typography.screenTitle)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text("Changes with your theme across the whole app. Pick a look now. The actual colors land later.")
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: .space12) {
                            ForEach(TonePaletteChoice.allCases) { palette in
                                TonePaletteRow(
                                    palette: palette,
                                    isSelected: stateModel.selectedTonePalette == palette
                                ) {
                                    actions.onSelectTonePalette?(palette)
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.42)
                }
            }
            // Same fix as `AgeStepView` - the vertical ScrollView's default
            // edge clipping was slicing the selected tone-palette row's
            // border (and, less noticeably, the theme card's) on the sides.
            .scrollClipDisabled()
        }
    }

    struct ThemePreviewCard: View {

        let theme: AppThemeChoice
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: .space8)
                            .fill(theme.previewBackground)
                            .frame(width: 56, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: .space8)
                                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: .space4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground)
                                .frame(width: 28, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground.opacity(0.6))
                                .frame(width: 20, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground.opacity(0.35))
                                .frame(width: 24, height: 4)
                        }
                        .padding(.space8)
                    }

                    VStack(alignment: .leading, spacing: .space4) {
                        Text(theme.title)
                            .font(Theme.Typography.onboardingBody.weight(.bold))
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                        Text(theme.subtitle)
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background.opacity(0.7) : Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: .space8)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.space16)
                .frame(maxWidth: .infinity, minHeight: 84)
                .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? theme.previewBackground : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct TonePaletteRow: View {

        let palette: TonePaletteChoice
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    HStack(spacing: -CGFloat.space8) {
                        ForEach(Array(palette.swatches.enumerated()), id: \.offset) { _, color in
                            Circle()
                                .fill(color)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle().stroke(
                                        isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.background,
                                        lineWidth: 2
                                    )
                                )
                        }
                    }

                    Text(palette.title)
                        .font(Theme.Typography.onboardingBody.weight(.bold))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                    Spacer(minLength: .space8)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.space16)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct IntroStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "text.bubble.fill", text: "Paste any text, DM, or email", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "camera.fill", text: "Or snap a screenshot instead", toneColor: Theme.Colors.Tone.passiveAggressive),
            Feature(icon: "sparkles", text: "Get the subtext or a perfect reply, instantly", toneColor: Theme.Colors.Tone.sarcastic)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space32) {
                VStack(alignment: .leading, spacing: .space12) {
                    Text("Here's what we do.")
                        .font(Theme.Typography.heroTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .onboardingReveal(delay: 0)

                    Text("No fluff. Just clarity on what people actually mean.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                        .onboardingReveal(delay: 0.12)
                }

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Array(Self.points.enumerated()), id: \.element.id) { index, point in
                        FinisherFeatureRow(icon: point.icon, text: point.text, toneColor: point.toneColor)
                            .onboardingReveal(delay: 0.24 + Double(index) * 0.1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
