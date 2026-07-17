//
//  CameraViewButton.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 12/07/2026.
//

import SwiftUI
import UIKit

struct BodyImage: Identifiable {
    // Sheet needs items to conform to Identifiable
    let id = UUID()
    let image: UIImage
}

struct CameraViewButton: View {
    @State private var isShowingCamera = false
    @State private var isCameraUnavailable = false
    @State private var isExtracting = false
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
                Image(systemName: "camera.fill")
                    .frame(width: 50, height: 50)
                    
            }
            .buttonStyle(.glassProminent)
            .tint(.Primary)
            .buttonBorderShape(.circle)
            .frame(width: 60, height: 60)
            .accessibilityLabel("Open camera")
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CustomCameraView { image in
                beginExtraction(from: image)
            }
        }
        .alert("Camera Unavailable", isPresented: $isCameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device does not have a camera, or the simulator cannot open one.")
        }
        .sheet(item: $imageSelected) { selected in
            ImagePreviewView(image: selected.image)
        }
        .overlay {
            if isExtracting {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)

                        Text("Extracting subject…")
                            .font(SofiaFont.medium(size: 15))
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Extracting subject")
            }
        }
    }

    private func beginExtraction(from image: UIImage) {
        isExtracting = true

        Task {
            defer { isExtracting = false }

            do {
                let extracted = try await SubjectExtractor.extractSubject(from: image)
                imageSelected = BodyImage(image: extracted)
            } catch {
                // Extraction failed — still open preview with the original as a fallback.
                imageSelected = BodyImage(image: image)
            }
        }
    }
}

#Preview {
    CameraViewButton()
}
