//
//  ReplyView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct ReplyView: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: ReplyViewModel
    
    init(output: @escaping (ReplyViewModel.Output) -> Void) {
        self.viewModel = .init(useMocks: true, output: output)
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

extension ReplyView {
    
    struct ContentView: View {
        let stateModel: ReplyViewModel.StateModel
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
                                    
                                    // 🪄 Dynamically grab properties from the Enum
                                    
                                    // TODO: update the naming
                                    let dynamicColor = toneAnalysis.tone.color
                                    let dynamicName = toneAnalysis.tone.rawValue.uppercased()
                                    
                                    // Tone Pill
                                    Text(dynamicName)
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(dynamicColor)
                                        .padding(.horizontal, .space12)
                                        .padding(.vertical, .space6)
                                        .background(dynamicColor.opacity(0.15))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(dynamicColor.opacity(0.4), lineWidth: 1))
                                    
                                    // Progress Bar
                                    GeometryReader { geo in
                                        Capsule()
                                            .fill(Colors.Main.borderSubtle)
                                            .overlay(alignment: .leading) {
                                                Capsule()
                                                    .fill(dynamicColor)
                                                    .frame(width: geo.size.width * CGFloat(toneAnalysis.score) / 100)
                                            }
                                    }
                                    .frame(height: 6)
                                    
                                    // Score
                                    Text("\(toneAnalysis.score)%")
                                        .font(Typography.badgeLabel)
                                        .foregroundStyle(dynamicColor)
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
                            ForEach(stateModel.options) { option in
                                ReplyOptionCard(option: option, actions: actions)
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
extension ReplyView.ContentView {
    
    struct ReplyOptionCard: View {
        let option: ReplyViewModel.StateModel.ReplyOption
        let actions: ReplyViewModel.Actions
            
        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                // Header
                HStack(spacing: .space8) {
                    Text(option.tone.emoji) // 🪄 Pulled from Enum
                        .font(.system(size: 20))
                    Text(option.tone.replyTitle) // 🪄 Pulled from Enum
                        .font(ReplyView.Typography.bodyText.weight(.bold))
                        .foregroundStyle(option.tone.color) // 🪄 Pulled from Enum
                }
                
                // Content
                Text(option.text)
                    .font(ReplyView.Typography.bodyText)
                    .foregroundStyle(ReplyView.Colors.Text.title)
                    .lineSpacing(4)
                
                // Actions
                HStack(spacing: .space12) {
                    Button {
                        actions.onEdit?(option)
                    } label: {
                        HStack(spacing: .space6) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .font(ReplyView.Typography.smallBody.weight(.bold))
                        .foregroundStyle(option.tone.color)
                        .padding(.vertical, 12)
                        .padding(.horizontal, .space16)
                        .background(ReplyView.Colors.Main.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(option.tone.color.opacity(0.4), lineWidth: 1)
                        )
                    }
                    
                    Button {
                        actions.onCopy?(option.text)
                    } label: {
                        HStack(spacing: .space6) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Reply")
                        }
                        .font(ReplyView.Typography.smallBody.weight(.bold))
                        .foregroundStyle(option.tone.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(option.tone.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.space16)
            .background(ReplyView.Colors.Main.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                    .stroke(option.tone.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ReplyView(output: { _ in })
}
