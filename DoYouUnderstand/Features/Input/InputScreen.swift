//
//  InputScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI
import PhotosUI

struct InputScreen: View {
    
    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors
    
    @State var viewModel: InputViewModel
    
    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        output: @escaping (InputViewModel.Output) -> Void
    ) {
        self.viewModel = .init(
            historyService: historyService,
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.actions.onTap?(.back)
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .accessibilityIdentifier("backButton")
            }
            ToolbarItem(placement: .principal) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text("NEW ANALYSIS")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    Text("Paste your text")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension InputScreen {

    struct ContentView: View {

        @Bindable var stateModel: InputViewModel.StateModel
        let actions: InputViewModel.Actions

        @FocusState private var isFocused: Bool

        var body: some View {
            ScrollView {
                VStack(spacing: .space24) {

                    // MARK: - Input Area -
                        
                        VStack(spacing: .space16) {
                            
                            if stateModel.images.isEmpty {
                                VStack(alignment: .leading, spacing: .space6) {
                                    ZStack(alignment: .topLeading) {

                                        if stateModel.inputText.isEmpty {
                                            Text("Paste text or write here...")
                                                .font(Typography.bodyText)
                                                .foregroundStyle(Colors.Text.muted)
                                                .padding(.horizontal, .space16)
                                                .padding(.vertical, .space16)
                                                .allowsHitTesting(false)
                                        }

                                        TextField("Paste text or write here...", text: $stateModel.inputText, axis: .vertical)
                                            .focused($isFocused)
                                            .font(Typography.bodyText)
                                            .foregroundStyle(Colors.Text.title)
                                            .tint(Colors.Main.primary)
                                            .lineLimit(8...(isFocused ? 8 : 15))
                                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                                            .padding(.horizontal, .space16)
                                            .padding(.vertical, .space16)

                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text(String(format: Loc.t("%d/%d chars"), stateModel.characterCount, stateModel.maxCharacters))
                                                    .font(Typography.smallBody)
                                                    .foregroundStyle(stateModel.isLimitExceeded ? Color.red : Colors.Text.muted)
                                                    .padding(.space12)
                                                    .animation(.easeInOut, value: stateModel.isLimitExceeded)
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

                                    // MARK: - Clear / Paste Text -
                                    HStack(spacing: .space12) {
                                        GlassPillButton(icon: "xmark", title: "Clear") {
                                            actions.onTap?(.clearText)
                                        }

                                        Spacer(minLength: .space8)

                                        GlassPillButton(icon: "doc.on.clipboard", title: "Paste") {
                                            actions.onTap?(.pasteText)
                                        }
                                    }
                                }
                            } else {
                                // MARK: - Photo gallery -
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: .space12) {
                                        ForEach(stateModel.images) { picked in
                                            Image(uiImage: picked.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 140, height: 168)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: .space12))
                                                .contentShape(RoundedRectangle(cornerRadius: .space12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: .space12)
                                                        .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                                )
                                                .overlay(alignment: .topTrailing) {
                                                    Button {
                                                        actions.onRemovePhoto?(picked.id)
                                                    } label: {
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 10, weight: .black))
                                                            .foregroundStyle(.white)
                                                            .frame(width: 24, height: 24)
                                                            .background(Color.black.opacity(0.6))
                                                            .clipShape(Circle())
                                                    }
                                                    .padding(.space8)
                                                }
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                    .padding(.horizontal, .space16)
                                    .padding(.vertical, .space16)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                                .background(Colors.Main.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                        .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                )
                            }
                            
                            // MARK: Action Buttons
                            HStack(spacing: .space12) {
                                let remainingSlots = stateModel.maxPhotos - stateModel.images.count
                                
                                if remainingSlots > 0 {
                                    PhotosPicker(
                                        selection: $stateModel.selectedPhotoItems,
                                        maxSelectionCount: remainingSlots,
                                        matching: .images
                                    ) {
                                        ActionLabel(icon: "photo", title: "Choose Photo")
                                    }
                                    .onChange(of: stateModel.selectedPhotoItems) { _, items in
                                        guard !items.isEmpty else { return }
                                        actions.onPhotosSelected?(items)
                                        stateModel.selectedPhotoItems.removeAll()
                                    }
                                } else {
                                    Button {} label: {
                                        ActionLabel(icon: "photo", title: String(format: Loc.t("Max %d Photos"), stateModel.maxPhotos))
                                    }
                                    .disabled(true)
                                    .opacity(0.5)
                                }
                                
                                Button {
                                    actions.onTap?(.takePhoto)
                                } label: {
                                    ActionLabel(icon: "camera", title: "Take Photo")
                                }
                                .disabled(remainingSlots <= 0)
                                .opacity(remainingSlots <= 0 ? 0.5 : 1.0)
                            }
                        }
                        
                        // MARK: - Selection cards -
                        
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
                }
            .scrollDismissesKeyboard(.interactively)
            // MARK: - SUBMIT BUTTON -
            .safeAreaInset(edge: .bottom) {
                Button {
                    actions.onAnalyse?()
                } label: {
                    HStack(spacing: .space8) {
                        Image(systemName: "bolt.fill")
                        Text("Analyze input")
                    }
                    .font(Typography.primaryButton)
                    .foregroundStyle(stateModel.isAnalysisEnabled ? Colors.Main.accent.contrastingForeground : Colors.Text.muted)
                }
                .buttonStyle(
                    LiquidGlassCTAButtonStyle(
                        tint: stateModel.isAnalysisEnabled ? Colors.Main.accent : Colors.Main.cardSurface,
                        isInteractive: stateModel.isAnalysisEnabled
                    )
                )
                .animation(.easeInOut, value: stateModel.isAnalysisEnabled)
                .disabled(!stateModel.isAnalysisEnabled)
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.bottom, .space12)
            }
            // MARK: - LOADING OVERLAY -
            .overlay {
                if stateModel.isLoaderPresented {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: .space16) {
                            BouncingDotsLoader(color: Colors.Main.accent, dotSize: 10)
                            Text(LocalizedStringKey(stateModel.loaderMessage))
                                .font(Typography.bodyText)
                                .foregroundStyle(.white)
                        }
                        .padding(.space32)
                        .background(Colors.Main.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: .space16))
                        .overlay(
                            RoundedRectangle(cornerRadius: .space16)
                                .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                        )
                    }
                    .allowsHitTesting(true)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: stateModel.isLoaderPresented)
            // MARK: - ERROR ALERT -
            .alert(
                "Analysis Failed",
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
            // MARK: - CAMERA -
            .fullScreenCover(isPresented: $stateModel.isCameraPresented) {
                CameraPicker(
                    onCapture: { image in actions.onPhotoCaptured?(image) },
                    onCancel: { actions.onCameraDismiss?() }
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Subcomponents
extension InputScreen {
    
    /// A compact, content-sized glass button - unlike `LiquidGlassCTAButtonStyle`
    /// (which always stretches to fill its container), `Clear`/`Paste` need to
    /// sit side by side at their natural width while still getting a real
    /// native-glass tap target (padding + `.glassEffect` + `.contentShape`)
    /// instead of bare icon+text with almost nothing to tap.
    struct GlassPillButton: View {
        let icon: String
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space6) {
                    Image(systemName: icon)
                    Text(LocalizedStringKey(title))
                }
                .font(Typography.smallBody.weight(.semibold))
                .foregroundStyle(Colors.Text.title)
                .padding(.horizontal, .space16)
                .padding(.vertical, 10)
                .glassEffect(.regular.interactive(), in: Capsule())
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    struct ActionLabel: View {
        let icon: String
        let title: String

        private var shape: RoundedRectangle {
            RoundedRectangle(cornerRadius: .space12, style: .continuous)
        }

        var body: some View {
            HStack(spacing: .space8) {
                Image(systemName: icon)
                Text(LocalizedStringKey(title))
            }
            .font(Typography.bodyText.weight(.semibold))
            .foregroundStyle(Colors.Main.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, .space16)
            .glassEffect(.regular.interactive(), in: shape)
            .contentShape(shape)
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
                    
                    Text(LocalizedStringKey(title))
                        .font(Typography.bodyText.weight(.bold))
                        .foregroundStyle(isSelected ? Colors.Main.primary : Colors.Text.title)

                    Text(LocalizedStringKey(subtitle))
                        .font(Typography.smallBody)
                        .foregroundStyle(Colors.Text.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, .space8)
                .background(isSelected ? Colors.Main.primary.opacity(0.05) : Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Colors.Main.primary : Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
        }
    }
}

#Preview {
    let view = InputScreen(historyService: MockHistoryService(), output: { _ in })
    view.viewModel.state = .loaded(InputViewModel.StateModel())
    return view
}
