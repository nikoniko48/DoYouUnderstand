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
    
    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        destination: ReplyViewModel.Destination,
        output: @escaping (ReplyViewModel.Output) -> Void
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

                        // MARK: - Generate More Tones
                        Button {
                            actions.onGenerateMoreTones?()
                        } label: {
                            HStack(spacing: .space8) {
                                if stateModel.isGeneratingMoreTones {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Generate More Tones")
                                }
                            }
                            .font(Typography.smallBody.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Colors.Main.accent)
                            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                        }
                        .disabled(stateModel.isGeneratingMoreTones)

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
                                .foregroundStyle(option.tone.color.contrastingForeground)
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
                            actions.onToggleTweak?(option.id)
                        } label: {
                            HStack(spacing: .space6) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Tweak")
                            }
                            .font(Theme.Typography.smallBody.weight(.bold))
                            .foregroundStyle(option.isTweaking ? option.tone.color.contrastingForeground : option.tone.color)
                            .padding(.vertical, 12)
                            .padding(.horizontal, .space16)
                            .background(option.isTweaking ? option.tone.color : Theme.Colors.Main.cardSurface)
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

                    if option.isTweaking {
                        TweakSection(option: $option, actions: actions)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
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
            .animation(.easeInOut(duration: 0.25), value: option.isTweaking)
        }
    }

    struct TweakSection: View {
        @Binding var option: ReplyViewModel.StateModel.ReplyOption
        let actions: ReplyViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space12) {
                HStack {
                    Text(option.tone.tweakLowLabel.uppercased())
                        .font(Theme.Typography.tinyLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)

                    Spacer()

                    Text(option.tone.tweakHighLabel.uppercased())
                        .font(Theme.Typography.tinyLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)
                }

                Slider(value: $option.tweakValue, in: 0...1)
                    .tint(option.tone.color)

                Button {
                    actions.onRegenerate?(option.id)
                } label: {
                    HStack(spacing: .space6) {
                        if option.isRegenerating {
                            ProgressView()
                                .tint(option.tone.color.contrastingForeground)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Regenerate")
                        }
                    }
                    .font(Theme.Typography.smallBody.weight(.bold))
                    .foregroundStyle(option.tone.color.contrastingForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(option.tone.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(option.isRegenerating)

                HStack(spacing: .space12) {
                    Button {
                        actions.onAdjustLength?(option.id, .shorten)
                    } label: {
                        Text("Shorten")
                            .font(Theme.Typography.smallBody.weight(.bold))
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                            )
                    }
                    .disabled(option.isRegenerating)

                    Button {
                        actions.onAdjustLength?(option.id, .lengthen)
                    } label: {
                        Text("Lengthen")
                            .font(Theme.Typography.smallBody.weight(.bold))
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                            )
                    }
                    .disabled(option.isRegenerating)
                }
            }
            .padding(.space12)
            .background(Theme.Colors.Main.background)
            .clipShape(RoundedRectangle(cornerRadius: .space12))
            .overlay(
                RoundedRectangle(cornerRadius: .space12)
                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ReplyScreen(
        historyService: MockHistoryService(),
        destination: .history(id: "mock_2"),
        output: { _ in }
    )
}
