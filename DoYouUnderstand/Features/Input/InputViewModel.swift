//
//  InputViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

import SwiftUI
import PhotosUI
import UIKit

@Observable
final class InputViewModel: StateViewModelProtocol {
    
    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let historyService: HistoryServiceProtocol

    // maybe update later
    private var useMocks: Bool

    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        useMocks: Bool = false,
        output: @escaping (Output) -> Void
    ) {
        self.historyService = historyService
        self.useMocks = useMocks
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension InputViewModel {
    
    enum Output {
        case goBack
        case explain(ExplanationViewModel.Payload)
        case reply(ReplyViewModel.Payload)
    }
}

// MARK: - Actions -

extension InputViewModel {
    
    struct Actions {
        var onAnalyse: (() -> Void)?
        var onTap: ((Tap) -> Void)?
        var onPhotosSelected: (([PhotosPickerItem]) -> Void)?
        var onRemovePhoto: ((UUID) -> Void)?
        var onPhotoCaptured: ((UIImage) -> Void)?
        var onCameraDismiss: (() -> Void)?
        
        enum Tap {
            case back
            case explain
            case reply
            case takePhoto
            case clearText
            case pasteText
        }
    }
    
    private func setActions() {
        
        actions.onAnalyse = { [weak self] in
            self?.analyse()
        }
        
        actions.onPhotosSelected = { [weak self] items in
            self?.loadPhotos(from: items)
        }
        
        actions.onRemovePhoto = { [weak self] id in
            self?.removePhoto(id: id)
        }

        actions.onPhotoCaptured = { [weak self] image in
            self?.handleCameraCapture(image)
        }

        actions.onCameraDismiss = { [weak self] in
            self?.stateModel.isCameraPresented = false
        }

        actions.onTap = { [weak self] tap in
            guard let self else { return }
            
            switch tap {
            case .back:
                goBack()
            case .reply:
                switchAnalysisType(to: .reply)
            case .explain:
                switchAnalysisType(to: .explain)
            case .takePhoto:
                takePhoto()
            case .clearText:
                clearText()
            case .pasteText:
                pasteText()
            }
        }
    }
}

// MARK: - Functions -

extension InputViewModel {
    
    private func analyse() {
        let text = stateModel.inputText
        let images = stateModel.images.compactMap { $0.image.jpegData(compressionQuality: 0.7) }
        let type = stateModel.selectedType

        stateModel.loaderMessage = "Analyzing your message..."
        stateModel.isLoaderPresented = true

        Task { [weak self] in
            guard let self else { return }
            do {
                switch type {
                case .explain:
                    let payload = try await GeminiService.explain(text: text, images: images)
                    self.historyService.save(.explanation(payload))
                    self.stateModel.isLoaderPresented = false
                    self.output(.explain(payload))
                case .reply:
                    let payload = try await GeminiService.reply(text: text, images: images)
                    self.historyService.save(.reply(payload))
                    self.stateModel.isLoaderPresented = false
                    self.output(.reply(payload))
                }
            } catch {
                self.stateModel.isLoaderPresented = false
                self.stateModel.errorMessage = "Couldn't analyze that message. Please try again."
            }
        }
    }
    
    private func goBack() {
        output(.goBack)
    }
    
    private func switchAnalysisType(to type: AnalysisType) {
        // Updates the selection card UI
        stateModel.selectedType = type
    }

    private func clearText() {
        stateModel.inputText = ""
    }

    private func pasteText() {
        guard let pasted = UIPasteboard.general.string, !pasted.isEmpty else { return }

        if stateModel.inputText.isEmpty {
            stateModel.inputText = pasted
        } else {
            stateModel.inputText += "\n" + pasted
        }
    }
    
    private func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // No camera hardware (e.g. Simulator) — fall back to a mock capture so the flow stays testable.
            if useMocks {
                appendPhoto(.mockCaptured)
            }
            return
        }

        stateModel.isCameraPresented = true
    }

    private func handleCameraCapture(_ image: UIImage) {
        stateModel.isCameraPresented = false
        appendPhoto(PickedImage(image: image))
    }

    private func appendPhoto(_ picked: PickedImage) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let combined = stateModel.images + [picked]
            stateModel.images = Array(combined.prefix(stateModel.maxPhotos))
        }
    }

    private func removePhoto(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            stateModel.images.removeAll { $0.id == id }
        }
    }
    
    private func loadPhotos(from items: [PhotosPickerItem]) {
        stateModel.isLoaderPresented = true
        
        Task {
            let decodedImages = await Task.detached {
                var loaded: [PickedImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        loaded.append(PickedImage(image: uiImage))
                    }
                }
                return loaded
            }.value
            
            await MainActor.run {
                let combined = self.stateModel.images + decodedImages
                self.stateModel.images = Array(combined.prefix(self.stateModel.maxPhotos))
                self.stateModel.isLoaderPresented = false
            }
        }
    }
}
