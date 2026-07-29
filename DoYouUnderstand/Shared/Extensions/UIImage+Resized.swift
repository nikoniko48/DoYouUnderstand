//
//  UIImage+Resized.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import UIKit

extension UIImage {

    /// Downscales so the longest side is at most `maxDimension`, leaving the
    /// image untouched if it's already smaller. Gemini doesn't need full-res
    /// screenshots to read text, and keeping the upload small avoids hitting
    /// payload/timeout limits.
    func resized(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
