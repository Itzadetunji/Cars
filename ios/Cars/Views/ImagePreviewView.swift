//
//  ImagePreviewView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import SwiftUI
import UIKit

struct ImagePreviewView: View {
    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    ImagePreviewView(image: UIImage(systemName: "photo")!)
}
