//
//  ReplyScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct ReplyScreen: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: ReplyViewModel
    
    init(historyItemId: String? = nil, output: @escaping (ReplyViewModel.Output) -> Void) {
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

extension ReplyScreen {
    
    struct ContentView: View {
        @Bindable var stateModel: ReplyViewModel.StateModel
        let actions: ReplyViewModel.Actions
        
        var body: some View {
            GeometryReader { proxy in
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
                                Text("REPLY GENERATOR")
                                    .font(Typography.badgeLabel)
                                    .foregroundStyle(Colors.Text.muted)
                                
                                Text("Pick your weapon")
                                    .font(Typography.screenTitle)
                                    .foregroundStyle(Colors.Text.title)
                            }
                            
                            Spacer()
                        }
                        
                        // MARK: - Tone Detected Card
                        if let toneAnalysis = stateModel.originalTone {
                            VStack(alignment: .leading, spacing: .space16) {
                                Text("ORIGINAL TONE DETECTED")
                                    .font(Typography.badgeLabel)
                                    .foregroundStyle(Colors.Text.muted)
                                
                                HStack(spacing: .space12) {
                                    Text(toneAnalysis.tone.rawValue.uppercased())
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(toneAnalysis.tone.color)
                                        .padding(.horizontal, .space12)
                                        .padding(.vertical, .space6)
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
                                
                                Text(toneAnalysis.quote)
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.muted)
                                    .lineSpacing(4)
                            }
                            .padding(.space16)
                            .background(Colors.Main.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                    .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                            )
                        }
                        
                        // MARK: - Reply Options Cards
                        VStack(spacing: .space16) {
                            ForEach($stateModel.options) { $option in
                                ReplyOptionCard(option: $option, actions: actions)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, StaticData.Layout.screenPadding)
                    .padding(.top, .space16)
                    .frame(minHeight: proxy.size.height)
                }
            }
        }
    }
}

// MARK: - Subcomponents
extension ReplyScreen {
    
    struct ReplyOptionCard: View {
        @Binding var option: ReplyViewModel.StateModel.ReplyOption
        let actions: ReplyViewModel.Actions
        @FocusState private var isFocused: Bool
            
        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                // Header
                HStack(spacing: .space8) {
                    Text(option.tone.emoji)
                        .font(.system(size: 20))
                    Text(option.tone.replyTitle)
                        .font(Theme.Typography.bodyText.weight(.bold))
                        .foregroundStyle(option.tone.color)
                }
                
                // Content Switcher
                if option.isEditing {
                    // MARK: Edit Mode
                    TextField("Edit your reply...", text: $option.draftText, axis: .vertical)
                        .focused($isFocused)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .tint(option.tone.color)
                        .lineLimit(4...12)
                        .padding(.horizontal, .space12)
                        .padding(.vertical, .space12)
                        .background(Theme.Colors.Main.background)
                        .clipShape(RoundedRectangle(cornerRadius: .space12))
                        .overlay(
                            RoundedRectangle(cornerRadius: .space12)
                                .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                        )
                        .transition(.scale)
                    
                    // Edit Actions
                    HStack(spacing: .space12) {
                        Button {
                            isFocused = false
                            actions.onCancelEdit?(option.id)
                        } label: {
                            Text("Cancel")
                                .font(Theme.Typography.smallBody.weight(.bold))
                                .foregroundStyle(Theme.Colors.Text.muted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Theme.Colors.Main.background)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                                )
                        }
                        
                        Button {
                            isFocused = false
                            actions.onSaveEdit?(option.id)
                        } label: {
                            Text("Save")
                                .font(Theme.Typography.smallBody.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(option.tone.color)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.opacity)
                    
                } else {
                    // MARK: View Mode
                    Text(option.text)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .lineSpacing(4)
                        .transition(.opacity)
                    
                    HStack(spacing: .space12) {
                        Button {
                            actions.onStartEdit?(option.id)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        } label: {
                            HStack(spacing: .space6) {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                            .font(Theme.Typography.smallBody.weight(.bold))
                            .foregroundStyle(option.tone.color)
                            .padding(.vertical, 12)
                            .padding(.horizontal, .space16)
                            .background(Theme.Colors.Main.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(option.tone.color.opacity(0.4), lineWidth: 1)
                            )
                        }
                        
                        Button {
                            actions.onCopy?(option.id)
                        } label: {
                            ZStack {
                                HStack(spacing: .space6) {
                                    Image(systemName: "checkmark")
                                    Text("Copied!")
                                }
                                .opacity(option.isCopied ? 1 : 0)
                                
                                HStack(spacing: .space6) {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Reply")
                                }
                                .opacity(option.isCopied ? 0 : 1)
                            }
                            .font(Theme.Typography.smallBody.weight(.bold))
                            .foregroundStyle(option.isCopied ? Theme.Colors.Main.success : option.tone.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(option.isCopied ? Theme.Colors.Main.success.opacity(0.12) : option.tone.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding(.space16)
            .background(Theme.Colors.Main.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                    .stroke(option.tone.color.opacity(0.3), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.25), value: option.isEditing)
            .animation(.easeInOut(duration: 0.25), value: option.isCopied)
        }
    }
}

#Preview {
    ReplyScreen(output: { _ in })
}
