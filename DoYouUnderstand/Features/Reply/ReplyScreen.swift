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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton { viewModel.actions.onTapBack?() }
            }
            ToolbarItem(placement: .principal) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text("REPLY GENERATOR")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    Text("Pick your weapon")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension ReplyScreen {

    struct ContentView: View {
        @Bindable var stateModel: ReplyViewModel.StateModel
        let actions: ReplyViewModel.Actions
        @State private var showBackToTop = false

        private static let topAnchorID = "replyTop"

        var body: some View {
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: .space24) {

                            Color.clear
                                .frame(height: 0)
                                .id(Self.topAnchorID)

                            if let toneAnalysis = stateModel.originalTone {
                                toneDetectedCard(toneAnalysis)
                            }

                            generateToneSection
                            optionsListSection

                            Spacer()
                        }
                        .padding(.horizontal, StaticData.Layout.screenPadding)
                        .padding(.top, .space16)
                        .frame(minHeight: proxy.size.height)
                    }
                    .scrollIndicators(.hidden)
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.y
                    } action: { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showBackToTop = newValue > 400
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if showBackToTop {
                            Button {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    scrollProxy.scrollTo(Self.topAnchorID, anchor: .top)
                                }
                            } label: {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Colors.Main.accent.contrastingForeground)
                                    .frame(width: 48, height: 48)
                                    .background(Colors.Main.accent)
                                    .clipShape(Circle())
                            }
                            .accessibilityIdentifier("scrollToTopButton")
                            .padding(.trailing, StaticData.Layout.screenPadding)
                            .padding(.bottom, .space24)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            // MARK: - DAILY LIMIT ALERT -
            .alert(
                "You're on a roll! 🔥",
                isPresented: Binding(
                    get: { stateModel.limitReachedMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.limitReachedMessage = nil }
                    }
                )
            ) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text(LocalizedStringKey(stateModel.limitReachedMessage ?? ""))
            }
            // MARK: - ERROR ALERT -
            .alert(
                "Something Went Wrong",
                isPresented: Binding(
                    get: { stateModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.errorMessage = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(LocalizedStringKey(stateModel.errorMessage ?? ""))
            }
        }

        // MARK: - Tone Detected Card -

        @ViewBuilder
        private func toneDetectedCard(_ toneAnalysis: ReplyViewModel.StateModel.ToneAnalysis) -> some View {
            VStack(alignment: .leading, spacing: .space16) {
                Text("ORIGINAL TONE DETECTED")
                    .font(Typography.badgeLabel)
                    .foregroundStyle(Colors.Text.muted)

                HStack(spacing: .space12) {
                    Text(toneAnalysis.tone.displayName.uppercased())
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
            .glassEffect(.regular.tint(toneAnalysis.tone.color.opacity(0.1)), in: RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous))
        }

        // MARK: - Generate A Specific Tone -

        @ViewBuilder
        private var generateToneSection: some View {
            if !stateModel.availableTones.isEmpty {
                VStack(alignment: .leading, spacing: .space12) {
                    Text("GENERATE A SPECIFIC TONE")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    FlowLayout(horizontalSpacing: .space8, verticalSpacing: .space8) {
                        ForEach(stateModel.availableTones, id: \.self) { tone in
                            Button {
                                actions.onGenerateTone?(tone)
                            } label: {
                                Text(tone.displayName)
                                    .font(Typography.smallBody.weight(.bold))
                                    .foregroundStyle(tone.color)
                                    .padding(.horizontal, .space12)
                                    .padding(.vertical, .space6)
                                    .background(tone.color.opacity(0.15))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(tone.color.opacity(0.4), lineWidth: 1))
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: .space8) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("That's every tone we've got!")
                }
                .font(Typography.smallBody.weight(.bold))
                .foregroundStyle(Colors.Text.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous))
            }
        }

        // MARK: - Reply Options Cards -

        @ViewBuilder
        private var optionsListSection: some View {
            VStack(spacing: .space16) {
                ForEach(stateModel.pendingTones, id: \.self) { tone in
                    ReplyOptionSkeletonCard(tone: tone)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                removal: .opacity
                            )
                        )
                }

                ForEach($stateModel.options) { $option in
                    ReplyOptionCard(option: $option, actions: actions)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.pendingTones)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.options)
        }
    }
}

// MARK: - Subcomponents
extension ReplyScreen {

    /// A placeholder shown at the top of the results list while an
    /// on-demand tone (a tapped pill) is being generated - swapped out for
    /// the real `ReplyOptionCard` the moment that one Gemini call resolves.
    struct ReplyOptionSkeletonCard: View {
        let tone: Tone
        @State private var isPulsing = false

        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                HStack(spacing: .space8) {
                    Text(tone.emoji)
                        .font(.system(size: 20))
                    Text(tone.replyTitle)
                        .font(Theme.Typography.bodyText.weight(.bold))
                        .foregroundStyle(tone.color)

                    Spacer()

                    BouncingDotsLoader(color: tone.color, dotSize: 6)
                }

                VStack(alignment: .leading, spacing: .space8) {
                    skeletonLine(widthFraction: 1)
                    skeletonLine(widthFraction: 0.9)
                    skeletonLine(widthFraction: 0.6)
                }
            }
            .padding(.space16)
            .glassEffect(.regular.tint(tone.color.opacity(0.1)), in: RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous))
            .onAppear { isPulsing = true }
        }

        private func skeletonLine(widthFraction: CGFloat) -> some View {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.Colors.Main.borderSubtle)
                    .frame(width: geo.size.width * widthFraction, height: 14)
            }
            .frame(height: 14)
            .opacity(isPulsing ? 0.4 : 1)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
        }
    }

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
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                    removal: .opacity
                                )
                            )
                    }
                }
            }
            .padding(.space16)
            .glassEffect(.regular.tint(option.tone.color.opacity(0.1)), in: RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous))
            .animation(.easeInOut(duration: 0.25), value: option.isEditing)
            .animation(.easeInOut(duration: 0.25), value: option.isCopied)
            // No .animation(value: option.isTweaking) here - toggleTweak()
            // already wraps the mutation in its own withAnimation(...). A
            // second implicit animation modifier on the same value fought
            // it (mismatched curve/duration), which is what caused the
            // janky top-to-bottom "flowing" text when expanding.
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

                HStack {
                    Text("LANGUAGE")
                        .font(Theme.Typography.tinyLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)

                    Spacer()

                    LanguageTogglePill(
                        activeLanguage: option.activeLanguage,
                        isDisabled: option.isRegenerating
                    ) { language in
                        actions.onChangeLanguage?(option.id, language)
                    }
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

    /// A compact `[ AUTO | EN ]` segmented toggle for overriding a single
    /// reply card's language for this session only.
    struct LanguageTogglePill: View {
        let activeLanguage: ReplyLanguage
        let isDisabled: Bool
        let onSelect: (ReplyLanguage) -> Void

        var body: some View {
            HStack(spacing: 2) {
                segment(.autoDetect, label: "AUTO")
                segment(.english, label: "EN")
            }
            .padding(2)
            .background(Theme.Colors.Main.background)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1))
            .opacity(isDisabled ? 0.5 : 1)
        }

        private func segment(_ language: ReplyLanguage, label: String) -> some View {
            let isActive = activeLanguage == language

            return Button {
                onSelect(language)
            } label: {
                Text(label)
                    .font(Theme.Typography.tinyLabel.weight(.bold))
                    .foregroundStyle(isActive ? Theme.Colors.Main.background : Theme.Colors.Text.muted)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(isActive ? Theme.Colors.Main.accent : Color.clear)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
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
