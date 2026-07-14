//
//  PhotosPickerItem+UIImage.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

extension PhotosPickerItem {
    /// Loads the selected photo as a `UIImage`.
    func loadUIImage() async -> UIImage? {
        try? await loadTransferable(type: PickedImage.self)?.uiImage
    }
}

private struct PickedImage: Transferable {
    let uiImage: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return PickedImage(uiImage: image)
        }
    }
}
