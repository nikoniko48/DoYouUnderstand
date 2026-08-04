//
//  OnboardingScreen+Animations.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

extension View {

    /// Fades and slides this view in shortly after it appears - used to give
    /// onboarding steps a staggered, "revealing" entrance instead of every
    /// element popping in at once.
    func onboardingReveal(delay: Double, from edge: Edge = .leading) -> some View {
        modifier(OnboardingRevealModifier(delay: delay, edge: edge))
    }

    /// Blends scrolled content into the page background near the top edge
    /// instead of the ScrollView's own hard clip boundary - for onboarding
    /// steps whose ScrollView sits directly below the shared progress-bar
    /// header, scrolling content used to just vanish at a flat line the
    /// instant it reached the ScrollView's top edge, which read as a jarring
    /// cutout. A background-colored gradient overlay (not a mask - the goal
    /// is to match the page background, not reveal what's behind it) fades
    /// that edge smoothly instead. `allowsHitTesting(false)` keeps it from
    /// blocking scroll gestures underneath.
    func onboardingScrollTopFade() -> some View {
        modifier(OnboardingScrollTopFadeModifier())
    }
}

private struct OnboardingScrollTopFadeModifier: ViewModifier {

    // The step's own title sits at the very top of the ScrollView's content,
    // so a fade that's always on would permanently cover part of it even at
    // rest (nothing scrolled yet, nothing to hide). Only fading it in once
    // the content has actually scrolled past the top keeps the title fully
    // visible until there's really something being clipped underneath.
    @State private var isScrolled = false

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isScrolled = newValue > 4
                }
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Theme.Colors.Main.background, Theme.Colors.Main.background.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)
                .opacity(isScrolled ? 1 : 0)
                .allowsHitTesting(false)
            }
    }
}

private struct OnboardingRevealModifier: ViewModifier {

    let delay: Double
    let edge: Edge

    @State private var isVisible = false

    private var hiddenOffset: CGSize {
        switch edge {
        case .leading: return CGSize(width: -28, height: 0)
        case .trailing: return CGSize(width: 28, height: 0)
        case .top: return CGSize(width: 0, height: -16)
        case .bottom: return CGSize(width: 0, height: 16)
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(isVisible ? .zero : hiddenOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// A single bar-chart column - percentage label, rising bar, and caption -
/// driven by one `percent` value. Bundling all three into one `Animatable`
/// view guarantees the label and the bar's height interpolate from the exact
/// same instantaneous value on every frame; splitting them across a plain
/// `@State`-driven frame height and a separate `Animatable` text view let
/// them fall out of sync (the frame modifier didn't pick up the animation at
/// all when the bar first appeared as part of the step's insertion
/// transition, while the `Animatable` text still counted up correctly).
struct OnboardingCountingBar: View, Animatable {

    var percent: Double
    let label: String
    let maxHeight: CGFloat
    let isHighlighted: Bool

    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }

    // The un-highlighted "before" bar used to fill with `Main.cardSurface` -
    // a flat, low-contrast neutral that (next to the highlighted bar's solid
    // `Main.accent` fill) read as a plain gray-or-white block sitting next
    // to a plain colored one, not much of a "chart." Tone colors for BOTH
    // bars (not `Main.accent` for the highlighted one - under Light theme
    // that's black, and a glass tint of black just renders as a flat gray,
    // the exact same "blob" problem moved to the other bar) plus the same
    // tinted-glass recipe used for cards elsewhere in the app gives both
    // bars real, theme-independent color and the same frosted depth as
    // everything else, instead of one flat block next to a flat tint.
    private var barColor: Color {
        isHighlighted ? Theme.Colors.Tone.empathetic : Theme.Colors.Tone.anxious
    }

    private var barShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 14,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 14,
            style: .continuous
        )
    }

    var body: some View {
        VStack(spacing: .space8) {
            Text("\(Int(percent.rounded()))%")
                .font(Theme.Typography.spaceGrotesk(size: 26, weight: .heavy))
                .foregroundStyle(isHighlighted ? barColor : Theme.Colors.Text.muted)
                .contentTransition(.numericText())

            // A fixed-height track holds the layout still - only the fill
            // inside it (anchored to the bottom) grows, so neither the
            // percent label above nor the caption below ever shifts.
            ZStack(alignment: .bottom) {
                Color.clear
                    .frame(height: maxHeight)

                Color.clear
                    .frame(height: max(4, maxHeight * CGFloat(percent / 100)))
                    .glassEffect(.regular.tint(barColor.opacity(0.5)), in: barShape)
                    .overlay(barShape.stroke(barColor.opacity(0.6), lineWidth: 1.5))
            }

            Text(label)
                .font(Theme.Typography.smallBody)
                .foregroundStyle(Theme.Colors.Text.muted)
        }
        .frame(maxWidth: .infinity)
    }
}
