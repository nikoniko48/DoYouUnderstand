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

    var body: some View {
        VStack(spacing: .space8) {
            Text("\(Int(percent.rounded()))%")
                .font(Theme.Typography.onboardingBody.weight(.bold))
                .foregroundStyle(isHighlighted ? Theme.Colors.Main.accent : Theme.Colors.Text.muted)

            // A fixed-height track holds the layout still - only the fill
            // inside it (anchored to the bottom) grows, so neither the
            // percent label above nor the caption below ever shifts.
            ZStack(alignment: .bottom) {
                Color.clear
                    .frame(height: maxHeight)

                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 10)
                    .fill(isHighlighted ? Theme.Colors.Main.accent : Theme.Colors.Main.cardSurface)
                    .overlay(
                        UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 10)
                            .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    .frame(height: max(4, maxHeight * CGFloat(percent / 100)))
            }

            Text(label)
                .font(Theme.Typography.smallBody)
                .foregroundStyle(Theme.Colors.Text.muted)
        }
        .frame(maxWidth: .infinity)
    }
}
