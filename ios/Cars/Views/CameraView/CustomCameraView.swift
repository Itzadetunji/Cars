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
    @State private var zoomAtPinchStart: CGFloat?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            CameraPreview(session: camera.session)  // full-bleed live feed
                .ignoresSafeArea()
                .gesture(pinchZoomGesture)
                .task { await camera.start() }
                .onDisappear { camera.stop() }

            VStack {

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .padding(.leading)
                    Spacer()
                }

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

                    HStack {
                        Spacer()

                        Button {
                            camera.toggleZoom()
                        } label: {
                            Text(camera.zoomLabel)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                        }
                        .frame(width: 64, height: 64)
                        .buttonStyle(.glass)
                        .accessibilityLabel("Toggle zoom")
                        .accessibilityValue(camera.zoomLabel)
                    }
                    .padding(.trailing, 16)
                }
            }
            .padding(.bottom, 64)
        }
    }

    private var pinchZoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if zoomAtPinchStart == nil {
                    zoomAtPinchStart = camera.zoomFactor
                }
                camera.setZoom((zoomAtPinchStart ?? 1) * value.magnification)
            }
            .onEnded { _ in
                zoomAtPinchStart = nil
            }
    }
}

#Preview {
    CustomCameraView { _ in }
}
