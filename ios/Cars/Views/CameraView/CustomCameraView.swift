//
//  CustomCameraView.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import AVFoundation
import SwiftUI

struct CustomCameraView: View {
  var onImageReady: (UIImage) -> Void
  @Environment(\.dismiss) private var dismiss

  @State private var camera = CameraModel()
  @State private var zoomAtPinchStart: CGFloat?
  @State private var showError = false

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      if camera.isRunning {
        CameraPreview(session: camera.session)
          .ignoresSafeArea()
      }

      controlsOverlay
    }
    .contentShape(Rectangle())
    .simultaneousGesture(camera.isRunning ? pinchZoomGesture : nil)
    .task {
      await camera.start()
    }
    .onDisappear {
      camera.stop()
    }
    .onChange(of: camera.errorMessage) { _, message in
      showError = message != nil
    }
    .alert("Camera Error", isPresented: $showError) {
      Button("OK") {
        camera.errorMessage = nil
        dismiss()
      }
    } message: {
      Text(camera.errorMessage ?? "Something went wrong with the camera.")
    }
  }

  private var controlsOverlay: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 54, height: 54)
        }
        .buttonStyle(.plain)
        .background(.black.opacity(0.45), in: Circle())
        .padding(.leading)
        
        Spacer()
      }

      Spacer()

      ZStack {
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
        .disabled(!camera.isRunning)

        HStack {
          Spacer()

          Button {
            camera.toggleZoom()
          } label: {
            Text(camera.zoomLabel)
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(.white)
              .frame(width: 64, height: 64)
          }
          .buttonStyle(.plain)
          .background(.black.opacity(0.45), in: Circle())
          .disabled(!camera.isRunning)
          .accessibilityLabel("Toggle zoom")
          .accessibilityValue(camera.zoomLabel)
        }
        .padding(.trailing, 16)
      }
    }
    .padding(.vertical, 32)
  }

  private var pinchZoomGesture: some Gesture {
    MagnifyGesture()
      .onChanged { value in
        if zoomAtPinchStart == nil {
          zoomAtPinchStart = camera.zoomFactor
        }

        let magnifyBy = (zoomAtPinchStart ?? 1) * value.magnification
        let clamped = min(max(magnifyBy, camera.minZoomFactor), min(camera.maxZoomFactor, 10))
        camera.setZoom(clamped)
      }
      .onEnded { _ in
        zoomAtPinchStart = nil
      }
  }
}

#Preview {
  CustomCameraView { _ in }
}
