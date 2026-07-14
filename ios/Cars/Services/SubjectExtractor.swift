//
//  SubjectExtractor.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import CoreImage
import ImageIO
import UIKit
import Vision

enum SubjectExtractorError: LocalizedError {
    case invalidImage
    case noSubjectFound
    case renderingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not read the photo."
        case .noSubjectFound:
            return "No subject was found in the photo."
        case .renderingFailed:
            return "Could not render the extracted subject."
        }
    }
}

enum SubjectExtractor {
    private static let context = CIContext(options: nil)

    /// Lifts the main foreground subject from a photo (on-device Vision).
    static func extractSubject(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw SubjectExtractorError.invalidImage
        }

        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let handler = ImageRequestHandler(cgImage, orientation: orientation)
        let request = GenerateForegroundInstanceMaskRequest()

        guard let observation = try await handler.perform(request) else {
            throw SubjectExtractorError.noSubjectFound
        }

        guard !observation.allInstances.isEmpty else {
            throw SubjectExtractorError.noSubjectFound
        }

        let maskedBuffer = try observation.generateMaskedImage(
            for: observation.allInstances,
            imageFrom: handler,
            croppedToInstancesExtent: true
        )

        let ciImage = CIImage(cvPixelBuffer: maskedBuffer)
        guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw SubjectExtractorError.renderingFailed
        }

        return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: .up)
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
