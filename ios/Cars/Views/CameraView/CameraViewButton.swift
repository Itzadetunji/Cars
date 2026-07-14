//
//  CameraViewButton.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI
import UIKit

struct BodyImage: Identifiable {
//    Sheet needs items to conform to identifiable so that's why we are doing this
    let id = UUID()
    let image: UIImage
}

struct CameraViewButton: View {
    @State private var isShowingCamera = false
    @State private var isCameraUnavailable = false
    @State private var imageSelected: BodyImage?

    var body: some View {
        VStack {
            Spacer()

            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingCamera = true
                } else {
                    isCameraUnavailable = true
                }
            } label: {
                Image(systemName: "camera")
                    .foregroundStyle(.background)
            }
            .buttonStyle(.plain)
            .frame(width: 60, height: 60)
            .background(.foreground)
            .clipShape(.rect(cornerRadius: .infinity))
            .accessibilityLabel("Open camera")
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CustomCameraView { image in
                imageSelected = BodyImage(image: image)
            }
            .ignoresSafeArea()
        }
        .alert("Camera Unavailable", isPresented: $isCameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device does not have a camera, or the simulator cannot open one.")
        }
        .sheet(item: $imageSelected) { selected in
            ImagePreviewView(image: selected.image)
        }
    }
}

#Preview {
    CameraViewButton()
}
