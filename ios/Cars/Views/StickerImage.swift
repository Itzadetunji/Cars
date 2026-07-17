//
//  StickerImage.swift
//  Cars
//
//  Die-cut sticker look: white contour padding + soft drop shadow.
//

import SwiftUI
import UIKit

struct StickerImage: View {
    private let source: UIImage
    var borderWidth: CGFloat
    var shadowRadius: CGFloat
    var shadowYOffset: CGFloat
    var shadowOpacity: Double

    @State private var sticker: UIImage?

    init(
        _ resource: ImageResource,
        borderWidth: CGFloat = 10,
        shadowRadius: CGFloat = 6,
        shadowYOffset: CGFloat = 3,
        shadowOpacity: Double = 0.28
    ) {
        self.source = UIImage(resource: resource)
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.shadowYOffset = shadowYOffset
        self.shadowOpacity = shadowOpacity
    }

    init(
        uiImage: UIImage,
        borderWidth: CGFloat = 10,
        shadowRadius: CGFloat = 6,
        shadowYOffset: CGFloat = 3,
        shadowOpacity: Double = 0.28
    ) {
        self.source = uiImage
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.shadowYOffset = shadowYOffset
        self.shadowOpacity = shadowOpacity
    }

    var body: some View {
        Image(uiImage: sticker ?? source)
            .resizable()
            .scaledToFit()
            .shadow(
                color: .black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: shadowYOffset
            )
            .task(id: borderWidth) {
                let image = source
                let width = borderWidth
                sticker = await Self.outline(image, borderWidth: width)
            }
    }

    private static func outline(_ image: UIImage, borderWidth: CGFloat) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = StickerEffect.outlined(image, borderWidth: borderWidth)
                continuation.resume(returning: result)
            }
        }
    }
}

/// Loads a remote image, applies the contour sticker border, then shadows it.
struct AsyncStickerImage: View {
    let url: URL?
    var borderWidth: CGFloat = 10
    var fallback: ImageResource = .toyota
    var shadowRadius: CGFloat = 6
    var shadowYOffset: CGFloat = 3
    var shadowOpacity: Double = 0.28

    @State private var sticker: UIImage?
    @State private var didFail = false

    var body: some View {
        Group {
            if let sticker {
                Image(uiImage: sticker)
                    .resizable()
                    .scaledToFit()
                    .shadow(
                        color: .black.opacity(shadowOpacity),
                        radius: shadowRadius,
                        x: 0,
                        y: shadowYOffset
                    )
            } else if didFail {
                StickerImage(
                    fallback,
                    borderWidth: borderWidth,
                    shadowRadius: shadowRadius,
                    shadowYOffset: shadowYOffset,
                    shadowOpacity: shadowOpacity
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 80)
            }
        }
        .task(id: url?.absoluteString) {
            await load()
        }
    }

    private func load() async {
        sticker = nil
        didFail = false

        guard let url else {
            didFail = true
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let loaded = UIImage(data: data) else {
                didFail = true
                return
            }

            let width = borderWidth
            sticker = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let result = StickerEffect.outlined(loaded, borderWidth: width)
                    continuation.resume(returning: result)
                }
            }
        } catch {
            didFail = true
        }
    }
}

#Preview {
    StickerImage(.extruded, borderWidth: 12)
        .frame(maxHeight: 120)
        .padding()
        .background(Color(white: 0.92))
}
