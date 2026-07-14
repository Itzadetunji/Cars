//
//  ImagePreviewView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import SwiftUI
import UIKit

struct ImagePreviewView: View {
    /// Already-extracted (or fallback) image — never the in-progress original.
    var image: UIImage

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
        }
    }
}

#Preview {
    ImagePreviewView(image: UIImage(systemName: "photo")!)
}
