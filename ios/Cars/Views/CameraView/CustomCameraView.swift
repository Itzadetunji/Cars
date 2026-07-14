//
//  CustomCameraView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import AVFoundation
import PhotosUI
import SwiftUI

struct CustomCameraView: View {
    var onImageReady: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var camera = CameraModel()  // AVFoundation wrapper
    @State private var photoItem: PhotosPickerItem?
    @State private var showLibrary = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            CameraPreview(session: camera.session)  // full-bleed live feed
                .ignoresSafeArea()
                .task { await camera.start() }
                .onDisappear { camera.stop() }

            VStack {
                Spacer()

                ZStack {
                    // Centered shutter (like left-1/2 -translate-x-1/2)
                    Button {
                        Task {
                            if let image = await camera.capturePhoto() {
                                onImageReady(image)
                                dismiss()
                            }
                        }
                    } label: {
                        Circle()
                            .fill(.white)
                            .padding(4)
                            .background(.black, in: Circle())
                            .padding(4)
                            .background(.white, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: 64, height: 64)
                    .accessibilityLabel("Capture")

                    // Gallery pinned 16pt from the left
                    HStack {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundStyle(.black)
                                .frame(width: 64, height: 64)
                        }
                        .background(.white, in: Circle())
                        .onChange(of: photoItem) { item in
                            Task {
                                if let image = await item?.loadUIImage() {
                                    onImageReady(image)
                                    dismiss()
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.leading, 32)
                }
            }
            .padding(.bottom, 64)
        }
    }
}

#Preview {
    CustomCameraView { _ in }
}
