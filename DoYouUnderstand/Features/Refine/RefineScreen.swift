//
//  RefineScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

struct RefineScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: RefineViewModel

    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        destination: RefineViewModel.Destination,
        output: @escaping (RefineViewModel.Output) -> Void
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
                    Text("REFINE")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    Text("Polish your message")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension RefineScreen {

    struct ContentView: View {

        @Bindable var stateModel: RefineViewModel.StateModel
        let actions: RefineViewModel.Actions

        @FocusState private var isDraftFieldFocused: Bool
        @FocusState private var isResultFieldFocused: Bool

        var body: some View {
            ScrollView {
                VStack(spacing: .space24) {

                    // MARK: - A. Transferred Draft Card
                    VStack(alignment: .leading, spacing: .space12) {
                        HStack {
                            Text("YOUR DRAFT")
                                .font(Typography.badgeLabel)
                                .foregroundStyle(Colors.Text.muted)

                            Spacer()

                            if !stateModel.isEditingDraft {
                                Button {
                                    actions.onStartEditDraft?()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isDraftFieldFocused = true
                                    }
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(Typography.smallBody.weight(.bold))
                                        .foregroundStyle(Colors.Main.primary)
                                }
                                .accessibilityLabel("Edit")
                            }
                        }

                        if stateModel.isEditingDraft {
                            TextField("Edit your draft...", text: $stateModel.draftEditText, axis: .vertical)
                                .focused($isDraftFieldFocused)
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.title)
                                .tint(Colors.Main.primary)
                                .lineLimit(4...12)

                            HStack(spacing: .space12) {
                                Button {
                                    isDraftFieldFocused = false
                                    actions.onCancelEditDraft?()
                                } label: {
                                    Text("Cancel")
                                        .font(Typography.smallBody.weight(.bold))
                                        .foregroundStyle(Colors.Text.muted)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Colors.Main.background)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                        )
                                }

                                Button {
                                    isDraftFieldFocused = false
                                    actions.onSaveEditDraft?()
                                } label: {
                                    Text("Save")
                                        .font(Typography.smallBody.weight(.bold))
                                        .foregroundStyle(Colors.Main.primary.contrastingForeground)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Colors.Main.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        } else {
                            Text(stateModel.originalMessage)
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.highlight)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.space16)
                    .background(Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0.06)

                    // MARK: - B. Tone Analysis Card
                    VStack(alignment: .leading, spacing: .space12) {
                        Text("DETECTED TONE")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)

                        if stateModel.isAnalyzingTone {
                            HStack(spacing: .space12) {
                                BouncingDotsLoader(color: Colors.Main.accent, dotSize: 8)
                                Text("Analyzing your draft...")
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.muted)
                            }
                        } else {
                            Text(stateModel.tone)
                                .font(Typography.biggerText.weight(.bold))
                                .foregroundStyle(stateModel.colorTone.color)

                            Text(stateModel.summary)
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.title)
                                .lineSpacing(4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.space16)
                    .background(stateModel.isAnalyzingTone ? Colors.Main.cardSurface : stateModel.colorTone.color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(stateModel.isAnalyzingTone ? Colors.Main.borderSubtle : stateModel.colorTone.color.opacity(0.4), lineWidth: stateModel.isAnalyzingTone ? 1 : 2)
                    )
                    .animation(.easeInOut(duration: 0.25), value: stateModel.isAnalyzingTone)
                    .onboardingReveal(delay: 0.12)

                    // MARK: - C. Refinement Quick-Actions
                    VStack(alignment: .leading, spacing: .space12) {
                        Text("REFINE IT")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: .space12), GridItem(.flexible(), spacing: .space12)], spacing: .space12) {
                            ForEach(RefineAction.allCases) { action in
                                RefineActionButton(
                                    action: action,
                                    isActive: stateModel.activeAction == action,
                                    isDisabled: stateModel.isRefining
                                ) {
                                    actions.onSelectAction?(action)
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.18)

                    // MARK: - D. Refined Result Card
                    if stateModel.isRefining && stateModel.refinedText == nil {
                        RefinedResultSkeletonCard()
                    } else if let refinedText = stateModel.refinedText {
                        VStack(alignment: .leading, spacing: .space16) {
                            HStack {
                                Text("REFINED VERSION")
                                    .font(Typography.badgeLabel)
                                    .foregroundStyle(Colors.Text.muted)

                                Spacer()

                                if stateModel.isRefining {
                                    BouncingDotsLoader(color: Colors.Main.accent, dotSize: 6)
                                }
                            }

                            if stateModel.isEditingResult {
                                TextField("Edit the refined text...", text: $stateModel.resultEditText, axis: .vertical)
                                    .focused($isResultFieldFocused)
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.title)
                                    .tint(Colors.Main.accent)
                                    .lineLimit(4...12)

                                HStack(spacing: .space12) {
                                    Button {
                                        isResultFieldFocused = false
                                        actions.onCancelEditResult?()
                                    } label: {
                                        Text("Cancel")
                                            .font(Typography.smallBody.weight(.bold))
                                            .foregroundStyle(Colors.Text.muted)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Colors.Main.background)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                            )
                                    }

                                    Button {
                                        isResultFieldFocused = false
                                        actions.onSaveEditResult?()
                                    } label: {
                                        Text("Save")
                                            .font(Typography.smallBody.weight(.bold))
                                            .foregroundStyle(Colors.Main.accent.contrastingForeground)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Colors.Main.accent)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            } else {
                                Text(refinedText)
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.title)
                                    .lineSpacing(4)
                                    .opacity(stateModel.isRefining ? 0.5 : 1)

                                HStack(spacing: .space12) {
                                    Button {
                                        actions.onStartEditResult?()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isResultFieldFocused = true
                                        }
                                    } label: {
                                        HStack(spacing: .space6) {
                                            Image(systemName: "pencil")
                                            Text("Edit")
                                        }
                                        .font(Typography.smallBody.weight(.bold))
                                        .foregroundStyle(Colors.Main.accent)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, .space16)
                                        .background(Colors.Main.cardSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Colors.Main.accent.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .disabled(stateModel.isRefining)

                                    Button {
                                        actions.onCopy?()
                                    } label: {
                                        ZStack {
                                            HStack(spacing: .space6) {
                                                Image(systemName: "checkmark")
                                                Text("Copied!")
                                            }
                                            .opacity(stateModel.isCopied ? 1 : 0)

                                            HStack(spacing: .space6) {
                                                Image(systemName: "doc.on.doc")
                                                Text("Copy Message")
                                            }
                                            .opacity(stateModel.isCopied ? 0 : 1)
                                        }
                                        .font(Typography.primaryButton)
                                        .foregroundStyle(Colors.Main.accent.contrastingForeground)
                                    }
                                    .buttonStyle(LiquidGlassCTAButtonStyle(tint: Colors.Main.accent, verticalPadding: .space12))
                                    .disabled(stateModel.isRefining)
                                }
                            }
                        }
                        .padding(.space16)
                        .background(Colors.Main.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                .stroke(Colors.Main.accent, lineWidth: 2)
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                    }

                    Spacer(minLength: .space16)
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .scrollDismissesKeyboard(.interactively)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: stateModel.refinedText)
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
            // MARK: - REFINE ACTION BLOCKED ALERT -
            .alert(
                "Can't Refine Further",
                isPresented: Binding(
                    get: { stateModel.refineActionBlockedMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.refineActionBlockedMessage = nil }
                    }
                )
            ) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text(LocalizedStringKey(stateModel.refineActionBlockedMessage ?? ""))
            }
        }
    }
}

// MARK: - Subcomponents

extension RefineScreen {

    /// A 2x2 grid card for each quick action - tinted Liquid Glass when
    /// active (same `.glassEffect(.regular.tint(_:).interactive())` idiom
    /// as the app's primary CTAs), plain untinted glass otherwise (matching
    /// Input's `ActionLabel`/`GlassPillButton`).
    struct RefineActionButton: View {
        let action: RefineAction
        let isActive: Bool
        let isDisabled: Bool
        let onTap: () -> Void

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
        }

        var body: some View {
            Button(action: onTap) {
                VStack(spacing: .space8) {
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isActive ? Theme.Colors.Main.accent.contrastingForeground : action.iconColor)

                    Text(action.title)
                        .font(Theme.Typography.smallBody.weight(.bold))
                        .foregroundStyle(isActive ? Theme.Colors.Main.accent.contrastingForeground : Theme.Colors.Text.title)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .space16)
                .padding(.horizontal, .space8)
                .glassEffect(
                    isActive
                        ? .regular.tint(Theme.Colors.Main.accent).interactive()
                        : .regular.interactive(),
                    in: shape
                )
                .contentShape(shape)
            }
            .disabled(isDisabled)
            .opacity(isDisabled && !isActive ? 0.5 : 1)
        }
    }

    struct RefinedResultSkeletonCard: View {
        @State private var isPulsing = false

        var body: some View {
            VStack(alignment: .leading, spacing: .space12) {
                HStack(spacing: .space8) {
                    Text("REFINED VERSION")
                        .font(Theme.Typography.badgeLabel)
                        .foregroundStyle(Theme.Colors.Text.muted)

                    Spacer()

                    BouncingDotsLoader(color: Theme.Colors.Main.accent, dotSize: 6)
                }

                VStack(alignment: .leading, spacing: .space8) {
                    skeletonLine(widthFraction: 1)
                    skeletonLine(widthFraction: 0.9)
                    skeletonLine(widthFraction: 0.6)
                }
            }
            .padding(.space16)
            .background(Theme.Colors.Main.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                    .stroke(Theme.Colors.Main.accent.opacity(0.3), lineWidth: 1)
            )
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
}

#Preview {
    RefineScreen(
        historyService: MockHistoryService(),
        destination: .draft("Hey, sorry to bother you again but I was just wondering if maybe you had a chance to look at that thing I sent over? No worries if not!"),
        output: { _ in }
    )
}
