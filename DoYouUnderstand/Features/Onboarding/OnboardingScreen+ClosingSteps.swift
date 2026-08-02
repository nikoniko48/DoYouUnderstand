//
//  OnboardingScreen+ClosingSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI
import UIKit

extension OnboardingScreen {

    struct PrivacyStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "lock.fill", text: "Messages are processed ephemerally and securely", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "internaldrive.fill", text: "History is saved strictly to your device's disk", toneColor: Theme.Colors.Tone.anxious),
            Feature(icon: "xmark.icloud.fill", text: "Zero cloud databases, no accounts required", toneColor: Theme.Colors.Tone.condescending)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                VStack(alignment: .leading, spacing: .space12) {
                    Text("Your Data is Safe With Us.")
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Everything runs on a local-first architecture. No accounts, no sign-up, no server-side profile of you.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }
                .onboardingReveal(delay: 0.1)

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

    /// Step 1 of the two-step paywall: the "marketing" pitch. Full-screen,
    /// no `ScrollView` - deliberately light on content (headline, urgency,
    /// the feature ticker) so it always fits without scrolling, unlike the
    /// old single-screen paywall it replaces. Its CTA (in the shared footer)
    /// never purchases directly - it just opens `CheckoutSheetView`, which
    /// owns pricing, the real purchase button, and all legal copy.
    struct FinisherStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions
        let isDiscountActive: Bool
        let discountExpiresAt: Date
        let now: Date

        private var remainingTimeString: String {
            let remaining = max(0, Int(discountExpiresAt.timeIntervalSince(now)))
            let hours = remaining / 3600
            let minutes = (remaining % 3600) / 60
            let seconds = remaining % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("PROFILE COMPLETE")
                    .font(Theme.Typography.badgeLabel)
                    .foregroundStyle(Theme.Colors.Tone.anxious)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(Theme.Colors.Tone.anxious.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Theme.Colors.Tone.anxious.opacity(0.4), lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0)

                VStack(alignment: .leading, spacing: .space12) {
                    Text("STOP OVERTHINKING\nYOUR TEXTS.")
                        .font(Theme.Typography.heroTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Get the subtext, craft the perfect response, and hit send with zero regrets.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }
                .onboardingReveal(delay: 0.1)

                if isDiscountActive {
                    HStack(spacing: .space6) {
                        Image(systemName: "clock.fill")
                        Text(String(format: Loc.t("LIMITED OFFER ENDS IN %@"), remainingTimeString))
                    }
                    .font(Theme.Typography.tinyLabel)
                    .foregroundStyle(Theme.Colors.Main.background)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(Theme.Colors.Main.accent)
                    .clipShape(Capsule())
                    .onboardingReveal(delay: 0.2)
                }

                // No `.frame(maxHeight: .infinity)` here on purpose: the
                // carousel already fixes its own height internally, and
                // proposing a flexible/ambiguous height from this ancestor
                // was the actual source of the centering bug below (it
                // triggered an extra, inconsistent layout pass that the
                // GeometryReader-driven offset math didn't recover from).
                FeatureCarousel()
                    .onboardingReveal(delay: 0.3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Step 2 of the two-step paywall: the "checkout" - a native bottom
    /// sheet presented over Step 1, so the marketing background stays
    /// visible behind it. Owns plan selection, the real RevenueCat purchase
    /// CTA, and every piece of legal/pricing copy the marketing step
    /// deliberately leaves out.
    struct CheckoutSheetView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions
        let isDiscountActive: Bool

        @State private var isShowingPrivacyPolicy = false
        @Environment(\.openURL) private var openURL

        // Apple's standard, boilerplate EULA - the one App Store Connect
        // auto-attaches to any subscription when no custom EULA is set.
        private static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                VStack(alignment: .leading, spacing: .space4) {
                    Text("Choose Your Plan")
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Cancel anytime before your trial ends and you won't be charged.")
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                }

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.PricingPlan.allCases) { plan in
                        PricingPlanRow(
                            plan: plan,
                            isSelected: stateModel.selectedPlan == plan,
                            isDiscountActive: isDiscountActive
                        ) {
                            actions.onSelectPlan?(plan)
                        }
                    }
                }

                if isDiscountActive {
                    HStack(spacing: .space6) {
                        Image(systemName: "tag.fill")
                        Text(String(format: Loc.t("You'll save %@ if you subscribe within the next 3 hours."), stateModel.selectedPlan.discountSavingsLabel))
                    }
                    .font(Theme.Typography.smallBody.weight(.bold))
                    .foregroundStyle(Theme.Colors.Main.success)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    actions.onStartTrial?()
                } label: {
                    Group {
                        if stateModel.isPurchasing {
                            ProgressView()
                                .tint(Theme.Colors.Main.accent.contrastingForeground)
                        } else {
                            Text("Start Free Trial")
                        }
                    }
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(Theme.Colors.Main.accent.contrastingForeground)
                }
                .buttonStyle(
                    LiquidGlassCTAButtonStyle(
                        tint: Theme.Colors.Main.accent
                    )
                )
                .disabled(stateModel.isPurchasing)

                VStack(spacing: .space8) {
                    Text(
                        String(
                            format: Loc.t("Then %@%@. Cancel anytime."),
                            stateModel.selectedPlan.price(discountActive: isDiscountActive),
                            stateModel.selectedPlan.period
                        )
                    )
                        .font(Theme.Typography.smallBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .multilineTextAlignment(.center)

                    Button {
                        actions.onRestorePurchases?()
                    } label: {
                        Text("Restore Purchases")
                            .font(Theme.Typography.smallBody)
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .underline()
                    }
                    .disabled(stateModel.isPurchasing)

                    HStack(spacing: .space16) {
                        Button {
                            openURL(Self.termsOfUseURL)
                        } label: {
                            Text("Terms of Use")
                        }

                        Button {
                            isShowingPrivacyPolicy = true
                        } label: {
                            Text("Privacy Policy")
                        }
                    }
                    .font(Theme.Typography.smallBody)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .underline()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space24)
            .padding(.bottom, .space16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.Main.background)
            .sheet(isPresented: $isShowingPrivacyPolicy) {
                NavigationStack {
                    PrivacyPolicyScreen(output: { _ in isShowingPrivacyPolicy = false })
                }
            }
        }
    }

    struct PricingPlanRow: View {

        let plan: OnboardingViewModel.StateModel.PricingPlan
        let isSelected: Bool
        let isDiscountActive: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space12) {
                    VStack(alignment: .leading, spacing: .space4) {
                        HStack(spacing: .space8) {
                            Text(plan.displayName)
                                .font(Theme.Typography.bodyText.weight(.bold))
                                .foregroundStyle(Theme.Colors.Text.title)

                            if let badge = plan.badge {
                                Text(badge)
                                    .font(Theme.Typography.tinyLabel)
                                    .foregroundStyle(Theme.Colors.Main.accent)
                                    .padding(.horizontal, .space6)
                                    .padding(.vertical, .space2)
                                    .overlay(
                                        Capsule().stroke(Theme.Colors.Main.accent, lineWidth: 1)
                                    )
                            }
                        }

                        if isDiscountActive {
                            HStack(spacing: .space6) {
                                Text(plan.standardPrice)
                                    .strikethrough()
                                    .foregroundStyle(Theme.Colors.Text.muted)

                                Text("\(plan.discountedPrice)\(plan.period)")
                                    .foregroundStyle(Theme.Colors.Text.title)
                            }
                            .font(Theme.Typography.smallBody)
                        } else {
                            Text("\(plan.standardPrice)\(plan.period)")
                                .font(Theme.Typography.smallBody)
                                .foregroundStyle(Theme.Colors.Text.title)
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle)
                }
                .padding(.space16)
                // Selected state used to fully invert to solid black/white,
                // which read as jarring next to the rest of the app's flat
                // dark cards - a soft accent tint + border communicates
                // selection just as clearly without the harsh flip, and
                // keeps all text at normal (never opacity-reduced) contrast.
                .background(isSelected ? Theme.Colors.Main.accent.opacity(0.12) : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle, lineWidth: isSelected ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    /// A high-converting interactive demo, right before the paywall: shows
    /// the exact same incoming message answered in 4 different tones, so
    /// the value of the tone system is felt rather than just described.
    /// Self-contained (no `stateModel`/`actions` in or out) - picking a
    /// pill only changes local `@State` for the demo card, nothing real.
    struct ToneDemoStepView: View {

        private struct DemoTone {
            let tone: Tone
            let label: String
            let replyText: String
        }

        // Computed, not `static let` - a `let` would cache whichever
        // language was active the first time this was read, and never
        // re-resolve after a live language switch in Settings.
        private static var demoTones: [DemoTone] {
            [
                DemoTone(tone: .savage, label: Loc.t("Savage"), replyText: Loc.t("Perfect. I'll do it my way then.")),
                DemoTone(tone: .flirty, label: Loc.t("Flirty"), replyText: Loc.t("Careful, I might just take you up on that. 😉")),
                DemoTone(tone: .diplomatic, label: Loc.t("De-escalate"), replyText: Loc.t("I sense some frustration. Let's figure out a solution we both like.")),
                DemoTone(tone: .professional, label: Loc.t("Professional"), replyText: Loc.t("I appreciate your flexibility. I will proceed as planned."))
            ]
        }

        /// How many tones exist beyond the 4 featured in this demo -
        /// derived from `Tone.allCases`, not hardcoded, so it can never
        /// drift out of sync as tones are added or removed.
        private static let remainingToneCount = Tone.allCases.count - demoTones.count

        @State private var selectedIndex = 0

        private var selected: DemoTone { Self.demoTones[selectedIndex] }

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                VStack(alignment: .leading, spacing: .space12) {
                    Text("Control any conversation.")
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("See how the exact same text changes based on your chosen tone.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }
                .onboardingReveal(delay: 0)

                IncomingMessageBubble(
                    senderLabel: Loc.t("INCOMING MESSAGE"),
                    text: Loc.t("Fine, do whatever you want."),
                    toneColor: Theme.Colors.Tone.passiveAggressive
                )
                .onboardingReveal(delay: 0.12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .space12) {
                        ForEach(Array(Self.demoTones.enumerated()), id: \.offset) { index, demo in
                            TonePillButton(
                                title: demo.label,
                                color: demo.tone.color,
                                isSelected: index == selectedIndex
                            ) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.vertical, .space4)
                }
                // The default ScrollView clip-to-bounds was slicing a
                // sliver off the selected pill's top/bottom border - the
                // pill row has nothing meaningful to hide off-screen
                // vertically, so disabling it here is safe.
                .scrollClipDisabled()
                .onboardingReveal(delay: 0.2)

                VStack(alignment: .leading, spacing: .space8) {
                    Text("YOUR REPLY")
                        .font(Theme.Typography.badgeLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)

                    // `.numericText()` is built for digits morphing in
                    // place - it doesn't read as "smooth" on prose, so a
                    // plain opacity cross-fade (keyed on the selected
                    // tone) is the actual "clean" transition here.
                    Text(selected.replyText)
                        .font(Theme.Typography.onboardingBody.weight(.semibold))
                        .foregroundStyle(Theme.Colors.Text.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(selected.tone)
                        .transition(.opacity)
                }
                .padding(.space16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                            .fill(selected.tone.color.opacity(0.22))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                        .stroke(selected.tone.color, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                .onboardingReveal(delay: 0.28)

                Text(String(format: Loc.t("Plus %d more custom tones available inside."), Self.remainingToneCount))
                    .font(Theme.Typography.smallBody)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .onboardingReveal(delay: 0.34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// A plain, non-selectable rendering of the same chat-bubble look
    /// `MessageBubbleOption` uses on the "which message triggers you" step
    /// (same shape, padding, and coloring) - for showing a static incoming
    /// message rather than a tappable option.
    struct IncomingMessageBubble: View {

        let senderLabel: String
        let text: String
        let toneColor: Color

        private var bubbleShape: UnevenRoundedRectangle {
            .rect(topLeadingRadius: 18, bottomLeadingRadius: 4, bottomTrailingRadius: 18, topTrailingRadius: 18)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: .space6) {
                Text(senderLabel)
                    .font(Theme.Typography.tinyLabel)
                    .foregroundStyle(toneColor)

                Text(text)
                    .font(Theme.Typography.onboardingBody)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, .space16)
                    .padding(.vertical, .space12)
                    .frame(maxWidth: 290, alignment: .leading)
                    .background(Theme.Colors.Main.cardSurface)
                    .clipShape(bubbleShape)
                    .overlay(
                        bubbleShape.stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// A selectable capsule chip for the tone-demo step - fills solid with
    /// the tone's own color when selected, matching the same "soft tint
    /// when active" language used elsewhere (pricing rows, gender chips).
    struct TonePillButton: View {

        let title: String
        let color: Color
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(Theme.Typography.bodyText.weight(.bold))
                    .foregroundStyle(isSelected ? color.contrastingForeground : Theme.Colors.Text.title)
                    .padding(.horizontal, .space16)
                    .padding(.vertical, .space12)
                    .background(isSelected ? color : Theme.Colors.Main.cardSurface)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(isSelected ? color : Theme.Colors.Main.borderSubtle, lineWidth: isSelected ? 2 : 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    /// The marketing step's centerpiece: big, center-focused feature cards
    /// that auto-advance through themselves - until the user so much as
    /// drags the row, at which point the auto-advance stops for good (it
    /// never re-arms; a manual swipe is a permanent opt-out, not a pause).
    /// This is a hand-rolled paging carousel (`.offset` driven by a plain
    /// `DragGesture`), not a native `ScrollView` - `.scrollTargetBehavior
    /// (.viewAligned)` turned out to always snap the focused card's
    /// *leading* edge to the same fixed inset (an Apple Music-style "peek
    /// on one side only" layout) no matter what anchor was requested, which
    /// isn't what a symmetric "peek on both sides" carousel needs. Doing
    /// the paging math directly makes the centering unambiguous: card N's
    /// resting offset is computed the same way every time, whether it's
    /// the first frame or the result of a drag.
    struct FeatureCarousel: View {

        struct Item: Identifiable {
            let id = UUID()
            let icon: String
            let title: String
            let subtitle: String
            let toneColor: Color
        }

        // Computed, not `static let` - see the note on `demoTones` above for
        // why (a `let` would cache whichever language was active first).
        private static var items: [Item] {
            [
                Item(icon: "lock.fill", title: Loc.t("100% Private"), subtitle: Loc.t("No accounts. No cloud storage. Ever."), toneColor: Theme.Colors.Tone.anxious),
                Item(icon: "bolt.fill", title: Loc.t("Instant AI Analysis"), subtitle: Loc.t("Get your answer in seconds, not minutes."), toneColor: Theme.Colors.Tone.overEager),
                Item(icon: "target", title: Loc.t("16 Reply Tones"), subtitle: Loc.t("From blunt to diplomatic, always the right voice."), toneColor: Theme.Colors.Tone.sarcastic),
                Item(icon: "sparkles", title: Loc.t("Context-Aware"), subtitle: Loc.t("Understands tone and nuance, not just keywords."), toneColor: Theme.Colors.Tone.professional),
                Item(icon: "pencil.line", title: Loc.t("Edit Any Reply"), subtitle: Loc.t("Tweak tone and wording until it's exactly right."), toneColor: Theme.Colors.Tone.playful)
            ]
        }

        // Both derived from the screen's own bounds - not a `GeometryReader`
        // reading of this view's own (flexible-height) allocated space,
        // which depends on an ancestor's `.frame(maxHeight: .infinity)`
        // negotiation and isn't stable by the time this body first renders
        // (the same class of first-layout-pass mismatch that made a preset
        // `.scrollPosition` unreliable earlier - see the type-level doc
        // comment above). A screen-relative static size has no such race.
        private static let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.78
        private static let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.34
        private static let cardSpacing: CGFloat = .space16
        private static let stride: CGFloat = cardWidth + cardSpacing
        // FeatureCarouselCard casts a drop shadow (radius 10, y offset 6)
        // that extends a few points past the card's own bounds - without
        // this breathing room, the outer `.clipped()` (needed to hide
        // off-screen cards during horizontal paging) was also slicing the
        // top/bottom of that shadow off the visible card.
        private static let verticalBleed: CGFloat = 20

        @State private var currentIndex = Self.items.count / 2
        @State private var dragTranslation: CGFloat = 0
        @State private var hasUserInteracted = false
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            GeometryReader { geo in
                let baseOffset = (geo.size.width - Self.cardWidth) / 2 - CGFloat(currentIndex) * Self.stride

                HStack(spacing: Self.cardSpacing) {
                    ForEach(Array(Self.items.enumerated()), id: \.element.id) { index, item in
                        FeatureCarouselCard(item: item)
                            .frame(width: Self.cardWidth, height: Self.cardHeight)
                    }
                }
                .offset(x: baseOffset + dragTranslation)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(height: Self.cardHeight + Self.verticalBleed * 2)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        hasUserInteracted = true
                        dragTranslation = value.translation.width
                    }
                    .onEnded { value in
                        let indexDelta = Int((-value.predictedEndTranslation.width / Self.stride).rounded())
                        let newIndex = min(max(currentIndex + indexDelta, 0), Self.items.count - 1)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            currentIndex = newIndex
                            dragTranslation = 0
                        }
                    }
            )
            .task {
                guard !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 2_600_000_000)
                    guard !Task.isCancelled, !hasUserInteracted else { return }
                    withAnimation(.easeInOut(duration: 0.7)) {
                        currentIndex = (currentIndex + 1) % Self.items.count
                    }
                }
            }
        }
    }

    struct FeatureCarouselCard: View {

        let item: FeatureCarousel.Item

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                Image(systemName: item.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(item.toneColor)

                Spacer(minLength: .space0)

                Text(item.title)
                    .font(Theme.Typography.hugeTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                Text(item.subtitle)
                    .font(Theme.Typography.bodyText)
                    // `.muted` reads as near-invisible against this card's
                    // tinted glass background - `.body` keeps the subtitle
                    // clearly secondary to the title while staying legible.
                    .foregroundStyle(Theme.Colors.Text.body)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                ZStack {
                    // Same hand-built glassmorphism recipe as
                    // `LiquidGlassCTAButtonStyle` - material base, a tone
                    // tint wash, and a top-down glare - so these cards read
                    // as the same "glass" material as the CTA buttons.
                    shape.fill(.ultraThinMaterial)
                    shape.fill(item.toneColor.opacity(0.3))
                    shape.fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .clipShape(shape)
            )
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0)],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: 1
                )
            )
            .overlay(
                shape.stroke(item.toneColor, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 6)
        }
    }
}
