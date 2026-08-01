//
//  ExplanationScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 22/07/2026.
//

import SwiftUI

struct ExplanationScreen: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: ExplanationViewModel
    
    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        destination: ExplanationViewModel.Destination,
        output: @escaping (ExplanationViewModel.Output) -> Void
    ) {
        self.viewModel = .init(historyService: historyService, destination: destination, output: output)
    }
    
    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(
                stateModel: stateModel,
                actions: viewModel.actions
            )
        }
        .navigationBarBackButtonHidden()
    }
}

extension ExplanationScreen {
    
    struct ContentView: View {
        @Bindable var stateModel: ExplanationViewModel.StateModel
        let actions: ExplanationViewModel.Actions
        
        // Triggers the text slide-in automatically
        @State private var showPrompt: Bool = false
        
        var body: some View {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: .space24) {
                            
                            // MARK: - Header
                            HStack(spacing: .space16) {
                                Button {
                                    actions.onTapBack?()
                                } label: {
                                    Image(systemName: "arrow.left")
                                        .font(Typography.bodyText)
                                        .scaleEffect(1.2)
                                        .foregroundStyle(Colors.Text.highlight)
                                        .frame(width: StaticData.Layout.backButtonSize.width, height: StaticData.Layout.backButtonSize.height)
                                        .background(Colors.Main.cardSurface)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: .space2) {
                                    Text("TONE ANALYSIS")
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(Colors.Text.muted)

                                    Text("Here's the truth")
                                        .font(Typography.screenTitle)
                                        .foregroundStyle(Colors.Text.title)
                                }
                                Spacer()
                            }
                            .onboardingReveal(delay: 0)

                            // MARK: - Original Message Card
                            VStack(alignment: .leading, spacing: .space12) {
                                Text("ORIGINAL MESSAGE")
                                    .font(Typography.badgeLabel)
                                    .foregroundStyle(Colors.Text.muted)

                                Text(stateModel.originalMessage)
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.highlight)
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.space16)
                            .background(Colors.Main.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                    .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                            )
                            .onboardingReveal(delay: 0.06)

                            // MARK: - Tone Progress Bar
                            if let toneAnalysis = stateModel.originalTone {
                                HStack(spacing: .space12) {
                                    Text(toneAnalysis.tone.rawValue.uppercased())
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(toneAnalysis.tone.color)
                                        .padding(.horizontal, .space12)
                                        .padding(.vertical, .space8)
                                        .background(toneAnalysis.tone.color.opacity(0.15))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(toneAnalysis.tone.color.opacity(0.4), lineWidth: 1))

                                    GeometryReader { geo in
                                        Capsule()
                                            .fill(Colors.Main.borderSubtle)
                                            .overlay(alignment: .leading) {
                                                Capsule()
                                                    .fill(toneAnalysis.tone.color)
                                                    .frame(width: geo.size.width * CGFloat(toneAnalysis.score) / 100)
                                            }
                                    }
                                    .frame(height: 6)

                                    Text("\(toneAnalysis.score)%")
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(toneAnalysis.tone.color)
                                }
                                .onboardingReveal(delay: 0.1)
                            }

                            // MARK: - Dynamic Breakdown Content
                            if let breakdown = stateModel.breakdown {
                                if stateModel.interactionStep == 0 {
                                    // Default Analysis Tiles
                                    VStack(spacing: .space16) {
                                        BreakdownTile(icon: "quote.opening", title: "WHAT THEY SAID", content: breakdown.said)
                                            .onboardingReveal(delay: 0.14)
                                        BreakdownTile(icon: "brain.head.profile", title: "WHAT THEY ACTUALLY MEANT", content: breakdown.meant)
                                            .onboardingReveal(delay: 0.18)
                                        BreakdownTile(icon: "eye.fill", title: "SUBTEXT", content: breakdown.subtext)
                                            .onboardingReveal(delay: 0.22)
                                        if let toneAnalysis = stateModel.originalTone {
                                            BreakdownTile(
                                                icon: "info.circle.fill",
                                                iconTint: toneAnalysis.tone.color,
                                                title: "WHAT DOES \(toneAnalysis.tone.rawValue.uppercased()) MEAN?",
                                                content: toneAnalysis.tone.definition
                                            )
                                            .onboardingReveal(delay: 0.26)
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .scale).combined(with: .opacity))
                                } else {
                                    // Plain-English Colorful Tile
                                    VStack(alignment: .leading, spacing: .space12) {
                                        HStack(spacing: .space8) {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(Colors.Main.primary)
                                            Text("Too Long; Didn't Read")
                                                .font(Typography.screenTitle)
                                                .foregroundStyle(Colors.Main.primary)
                                        }

                                        Text(breakdown.eli5)
                                            .font(Typography.biggerText)
                                            .foregroundStyle(Colors.Text.title)
                                            .lineSpacing(6)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.space24)
                                    .background(Colors.Main.cardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                            .stroke(Colors.Main.primary, lineWidth: 2)
                                    )
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity).combined(with: .opacity))
                                }
                            }

                            Spacer(minLength: 120) // Give space for the bottom button area
                        }
                        .padding(.horizontal, StaticData.Layout.screenPadding)
                        .padding(.top, .space16)
                        .frame(minHeight: proxy.size.height)
                    }
                    
                    // MARK: - Floating Action Area
                    VStack(spacing: .space12) {
                        
                        // Prompt text automatically slides in from the left on view load
                        if stateModel.interactionStep == 0 && showPrompt {
                            Text("Still confused? Let's cut to the chase.")
                                .font(Typography.smallBody.weight(.bold))
                                .foregroundStyle(Colors.Text.muted)
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity).combined(with: .opacity))
                        }
                        
                        Button {
                            actions.onTapMainAction?()
                        } label: {
                            Text(stateModel.interactionStep == 0 ? "YEA!" : "GOT IT!")
                                .font(Typography.primaryButton)
                                .foregroundStyle(Colors.Main.accent.contrastingForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Colors.Main.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, StaticData.Layout.screenPadding)
                    .padding(.top, .space12)
                    .padding(.bottom, .space24)
                    .background(
                        // A short fade rather than a large opaque block
                        // extending arbitrarily far above this footer's own
                        // bounds - that used to blot out most of the last
                        // tile above it. This floats over just enough to
                        // read clearly against whatever scrolls underneath.
                        LinearGradient(
                            colors: [Colors.Main.background.opacity(0), Colors.Main.background],
                            startPoint: .top,
                            endPoint: .init(x: 0.5, y: 0.35)
                        )
                        .ignoresSafeArea()
                    )
                }
                .onAppear {
                    // Triggers the text slide-in nicely after a tiny delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showPrompt = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subcomponents
extension ExplanationScreen {
    
    struct BreakdownTile: View {
        let icon: String
        var iconTint: Color = Theme.Colors.Main.accent
        let title: String
        let content: String

        var body: some View {
            HStack(alignment: .top, spacing: .space12) {
                Image(systemName: icon)
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(iconTint.contrastingForeground)
                    .frame(width: 32, height: 32)
                    .background(iconTint)
                    .clipShape(RoundedRectangle(cornerRadius: .space8))

                VStack(alignment: .leading, spacing: .space8) {
                    Text(title)
                        .font(Theme.Typography.badgeLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)

                    Text(content)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .lineSpacing(4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.space16)
            .background(Theme.Colors.Main.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ExplanationScreen(
        historyService: MockHistoryService(),
        destination: .history(id: "mock_1"),
        output: { _ in }
    )
}
