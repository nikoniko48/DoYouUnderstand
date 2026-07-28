//
//  PickedImage+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 28/07/2026.
//

import UIKit

extension InputViewModel.PickedImage {

    static var mockCaptured: InputViewModel.PickedImage {
        .init(image: .mockCameraCapture)
    }
}

private extension UIImage {

    static var mockCameraCapture: UIImage {
        let size = CGSize(width: 320, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            UIColor.darkGray.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))

            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold)
            let symbol = UIImage(systemName: "camera.fill", withConfiguration: symbolConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)

            symbol?.draw(at: CGPoint(
                x: (size.width - (symbol?.size.width ?? 0)) / 2,
                y: (size.height - (symbol?.size.height ?? 0)) / 2
            ))
        }
    }
}
