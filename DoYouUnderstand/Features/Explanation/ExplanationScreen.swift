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
    
    init(historyItemId: String? = nil, output: @escaping (ExplanationViewModel.Output) -> Void) {
        self.viewModel = .init(useMocks: true, historyItemId: historyItemId, output: output)
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
                            }
                            
                            // MARK: - Dynamic Breakdown Content
                            if let breakdown = stateModel.breakdown {
                                if stateModel.interactionStep == 0 {
                                    // Default Analysis Tiles
                                    VStack(spacing: .space16) {
                                        BreakdownTile(title: "WHAT THEY SAID", content: breakdown.said)
                                        BreakdownTile(title: "WHAT THEY ACTUALLY MEANT", content: breakdown.meant)
                                        BreakdownTile(title: "SUBTEXT", content: breakdown.subtext)
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .scale).combined(with: .opacity))
                                } else {
                                    // ELI5 Colorful Tile
                                    VStack(alignment: .leading, spacing: .space12) {
                                        HStack {
                                            Text("🍼")
                                                .font(.system(size: 24))
                                            Text("EXPLAINED LIKE YOU'RE 5")
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
                            Text("Still confused? Let's dumb it down.")
                                .font(Typography.smallBody.weight(.bold))
                                .foregroundStyle(Colors.Text.muted)
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity).combined(with: .opacity))
                        }
                        
                        Button {
                            actions.onTapMainAction?()
                        } label: {
                            Text(stateModel.interactionStep == 0 ? "YEA!" : "GOT IT!")
                                .font(Typography.primaryButton)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Colors.Main.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, StaticData.Layout.screenPadding)
                    .padding(.bottom, .space24)
                    .background(
                        Colors.Main.background
                            .padding(.top, -40)
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
        let title: String
        let content: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: .space8) {
                Text(title)
                    .font(Theme.Typography.badgeLabel)
                    .foregroundStyle(Theme.Colors.Text.muted)
                
                Text(content)
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .lineSpacing(4)
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
    ExplanationScreen(output: { _ in })
}
