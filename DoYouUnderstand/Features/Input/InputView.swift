//
//  InputView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct InputView: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: InputViewModel
    
    init(output: @escaping (InputViewModel.Output) -> Void) {
        self.viewModel = .init(
            useMocks: true,
            output: output
        )
    }
    
    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(
                stateModel: stateModel,
                actions: viewModel.actions
            )
        }
    }
}

extension InputView {
    
    struct ContentView: View {
        
        let stateModel: InputViewModel.StateModel
        let actions: InputViewModel.Actions
        
        var body: some View {
            VStack(spacing: .space24) {
                
                // MARK: - Header -
                
                HStack(spacing: .space16) {
                    Button {
                        actions.onTap?(.back)
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
                        Text("NEW ANALYSIS")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)
                        
                        Text("Paste your text")
                            .font(Typography.screenTitle)
                            .foregroundStyle(Colors.Text.title)
                    }
                    
                    Spacer()
                }
                
                
                // MARK: - Text input area -
                
                VStack(spacing: .space16) {
                    ZStack(alignment: .topLeading) {
                        
                        if stateModel.inputText.isEmpty {
                            Text("Paste text or write here...")
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.muted)
                                .padding(.horizontal, .space16)
                                .padding(.vertical, .space16)
                                .allowsHitTesting(false)
                        }
                        
                        TextField("", text: Binding(
                            get: { stateModel.inputText },
                            set: { actions.onUpdateText?($0) }
                        ), axis: .vertical)
                        .font(Typography.bodyText)
                        .foregroundStyle(Colors.Text.title)
                        .tint(Colors.Main.primary)
                        .lineLimit(8...12)
                        .padding(.horizontal, .space16)
                        .padding(.vertical, .space16)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(stateModel.characterCount) chars")
                                    .font(Typography.smallBody)
                                    .foregroundStyle(Colors.Text.muted)
                                    .padding(.space12)
                            }
                        }
                    }
                    .frame(minHeight: 200)
                    .background(Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    
                    HStack(spacing: .space12) {
                        ActionButton(icon: "photo", title: "Choose Photo") {}
                        ActionButton(icon: "camera", title: "Take Photo") {}
                    }
                }
                
                // --- 4. SELECTION CARDS ---
                VStack(alignment: .leading, spacing: .space12) {
                    Text("WHAT DO YOU NEED?")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)
                    
                    HStack(spacing: .space12) {
                        SelectionCard(
                            emoji: "🔎",
                            title: "Explanation",
                            subtitle: "Decode what they meant",
                            isSelected: stateModel.selectedType == .explain
                        ) {
                            actions.onTap?(.explain)
                        }
                        
                        SelectionCard(
                            emoji: "✍️",
                            title: "Reply",
                            subtitle: "Craft your response",
                            isSelected: stateModel.selectedType == .reply
                        ) {
                            actions.onTap?(.reply)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space16)
            
            // --- 5. SUBMIT BUTTON ---
            .safeAreaInset(edge: .bottom) {
                Button {
                    actions.onAnalyse?()
                } label: {
                    HStack(spacing: .space8) {
                        Image(systemName: "bolt.fill")
                        Text("Analyze text")
                    }
                    .font(Typography.primaryButton)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        stateModel.isAnalysisEnabled
                        ? Colors.Main.accent
                        : Colors.Main.cardSurface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .animation(.easeInOut, value: stateModel.isAnalysisEnabled)
                }
                .disabled(!stateModel.isAnalysisEnabled)
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.bottom, .space12)
            }
        }
    }
}

// MARK: - Subcomponents
extension InputView.ContentView {
    
    struct ActionButton: View {
        let icon: String
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: .space8) {
                    Image(systemName: icon)
                    Text(title)
                }
                .font(InputView.Typography.bodyText.weight(.semibold))
                .foregroundStyle(InputView.Colors.Main.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .space16)
                .background(InputView.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(InputView.Colors.Main.borderSubtle, lineWidth: 1)
                )
            }
        }
    }
    
    struct SelectionCard: View {
        let emoji: String
        let title: String
        let subtitle: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: .space8) {
                    Text(emoji)
                        .font(.system(size: 28))
                        .padding(.bottom, .space4)
                    
                    Text(title)
                        .font(InputView.Typography.bodyText.weight(.bold))
                        .foregroundStyle(isSelected ? InputView.Colors.Main.primary : InputView.Colors.Text.title)
                    
                    Text(subtitle)
                        .font(InputView.Typography.smallBody)
                        .foregroundStyle(InputView.Colors.Text.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, .space8)
                .background(isSelected ? InputView.Colors.Main.primary.opacity(0.05) : InputView.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? InputView.Colors.Main.primary : InputView.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
    }
}

#Preview {
    let view = InputView(output: { _ in })
    
    view.viewModel.state = .loaded(
        InputViewModel.StateModel()
    )
    
    return view
}
