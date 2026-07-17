//
//  StickerEffect.swift
//  Cars
//
//  Contour-following white border + alpha-aware sticker treatment.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum StickerEffect {
    /// Dilates the image’s alpha path into a solid white outline, then draws the
    /// original subject on top — like a die-cut sticker border.
    static func outlined(
        _ image: UIImage,
        borderWidth: CGFloat = 10,
        borderColor: CIColor = .white,
        maxDimension: CGFloat = 600
    ) -> UIImage {
        let source = downsampled(image, maxDimension: maxDimension) ?? image

        // HEIC / asset images may not expose `cgImage` until rendered.
        let input: CIImage
        if let cgImage = source.cgImage {
            input = CIImage(cgImage: cgImage)
        } else if let ciImage = CIImage(image: source) {
            input = ciImage
        } else {
            return image
        }

        let context = CIContext(options: [.cacheIntermediates: false])
        let radius = max(borderWidth * source.scale, 1)

        // Finite canvas: subject inset so dilation has room and never goes infinite.
        let canvas = CGRect(
            x: 0,
            y: 0,
            width: input.extent.width + radius * 2,
            height: input.extent.height + radius * 2
        )

        let padded = input.transformed(
            by: CGAffineTransform(translationX: radius, y: radius)
        )

        // Alpha → RGB silhouette so morphology expands the opaque shape.
        let alphaMask = padded.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            ]
        ).cropped(to: canvas)

        let morphology = CIFilter.morphologyMaximum()
        morphology.inputImage = alphaMask
        morphology.radius = Float(min(radius, 40))

        guard let dilated = morphology.outputImage?.cropped(to: canvas) else {
            return source
        }

        let clear = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0))
            .cropped(to: canvas)
        let white = CIImage(color: borderColor).cropped(to: canvas)

        let borderLayer = white.applyingFilter(
            "CIBlendWithAlphaMask",
            parameters: [
                kCIInputBackgroundImageKey: clear,
                kCIInputMaskImageKey: dilated,
            ]
        )

        let composited = padded.cropped(to: canvas).composited(over: borderLayer)

        guard let output = context.createCGImage(composited, from: canvas) else {
            return source
        }

        return UIImage(cgImage: output, scale: source.scale, orientation: .up)
    }

    private static func downsampled(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        return image.preparingThumbnail(of: target)
    }
}
