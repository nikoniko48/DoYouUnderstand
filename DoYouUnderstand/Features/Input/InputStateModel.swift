//
//  InputStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

import UIKit
import PhotosUI
import SwiftUI

extension InputViewModel {
    
    @Observable
    final class StateModel: StateModelProtocol {
        let maxCharacters: Int = 360
        let maxPhotos: Int = 6
        var isLoaderPresented: Bool = false
        var loaderMessage: String = "Processing photos..."
        var errorMessage: String?
        var limitReachedMessage: String?
        var isCameraPresented: Bool = false
        var inputText: String = ""
        var selectedType: AnalysisType = .explain
        var images: [PickedImage] = []
        var selectedPhotoItems: [PhotosPickerItem] = []

        var characterCount: Int {
            inputText.count
        }
        
        var isLimitExceeded: Bool {
            inputText.count > maxCharacters
        }
        
        var isAnalysisEnabled: Bool {
            let hasContent = !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !images.isEmpty
            return hasContent && !isLimitExceeded
        }
    }
    
    struct PickedImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }
}
