//
//  BouncingDotsLoader.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

/// A brutalist-friendly stand-in for the native `ProgressView` spinner - three
/// dots bouncing in a staggered wave. Meant for use inside buttons/inline
/// loading states where the system spinner feels out of place.
struct BouncingDotsLoader: View {

    var color: Color = .white
    var dotSize: CGFloat = 6

    @State private var isBouncing = false

    var body: some View {
        HStack(spacing: dotSize * 0.7) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: isBouncing ? -dotSize * 0.7 : 0)
                    .animation(
                        .easeInOut(duration: 0.45)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: isBouncing
                    )
            }
        }
        .onAppear { isBouncing = true }
    }
}

#Preview {
    BouncingDotsLoader(color: .black)
        .padding()
}
