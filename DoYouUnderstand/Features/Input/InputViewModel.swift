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
    
    // maybe update later
    private var useMocks: Bool
    
    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
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
        case explain
        case reply
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
            }
        }
    }
}

// MARK: - Functions -

extension InputViewModel {
    
    private func analyse() {
        // TODO: Backend Call Implementation
        // Here is where you will send `stateModel.inputText` and `stateModel.selectedType` to your server.
        print("Submitting text: \(stateModel.inputText) for type: \(stateModel.selectedType)")
        
        // Once the backend returns success, route to the next screen based on selection:
        switch stateModel.selectedType {
        case .explain:
            output(.explain)
        case .reply:
            output(.reply)
        }
    }
    
    private func goBack() {
        output(.goBack)
    }
    
    private func switchAnalysisType(to type: AnalysisType) {
        // Updates the selection card UI
        stateModel.selectedType = type
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
