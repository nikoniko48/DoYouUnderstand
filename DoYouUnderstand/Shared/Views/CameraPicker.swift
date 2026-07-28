//
//  CameraPicker.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 28/07/2026.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {

    var onCapture: (UIImage) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, onCancel: onCancel)
    }
}

extension CameraPicker {

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        private let onCapture: (UIImage) -> Void
        private let onCancel: () -> Void

        init(onCapture: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
