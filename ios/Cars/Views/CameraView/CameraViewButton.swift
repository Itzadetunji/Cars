//
//  CameraViewButton.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI

struct CameraViewButton: View {
    @State private var isShowingCamera = false
    @State private var isCameraUnavailable = false

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
            .cornerRadius(.infinity)
            .accessibilityLabel("Open camera")
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { _ in
                // Handle the captured photo here.
            }
            .ignoresSafeArea()
        }
        .alert("Camera Unavailable", isPresented: $isCameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device does not have a camera, or the simulator cannot open one.")
        }
    }
}

#Preview {
    CameraViewButton()
}
