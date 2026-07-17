//
//  CameraModel.swift
//  Cars
//
//  Created by Adetunji Adeyinka on 14/07/2026.
//

import AVFoundation
import UIKit

@Observable
@MainActor
final class CameraModel {
  let session = AVCaptureSession()

  private let photoOutput = AVCapturePhotoOutput()
  private let sessionQueue = DispatchQueue(label: "com.cars.camera.session")
  private var device: AVCaptureDevice?
  private var photoDelegate: PhotoCaptureDelegate?
  private var hasStarted = false

  private(set) var isRunning = false
  /// Zoom factor shown in the UI (0.5×, 1.0×, 2.2×, …), not raw `videoZoomFactor`.
  private(set) var zoomFactor: CGFloat = 1
  var errorMessage: String?

  var zoomLabel: String {
    String(format: "%.1fx", zoomFactor)
  }

  /// Smallest zoom the UI can show (typically 0.5× on ultra-wide devices).
  var minZoomFactor: CGFloat {
    guard let device else { return 1 }
    return device.minAvailableVideoZoomFactor * device.displayVideoZoomFactorMultiplier
  }

  /// Largest zoom the UI can show.
  var maxZoomFactor: CGFloat {
    guard let device else { return 1 }
    let maxVideo = min(device.maxAvailableVideoZoomFactor, device.activeFormat.videoMaxZoomFactor)
    return maxVideo * device.displayVideoZoomFactorMultiplier
  }

  func start() async {
    guard !hasStarted else { return }
    hasStarted = true
    defer {
      if !isRunning {
        hasStarted = false
      }
    }

    let authorized = await Self.requestAccess()
    guard authorized else {
      errorMessage = "Camera access was denied."
      return
    }

    do {
      try await configureSession()
      try await startRunningAndApplyDefaultZoom()
      isRunning = true
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func stop() {
    hasStarted = false
    isRunning = false

    sessionQueue.async { [session] in
      guard session.isRunning else { return }
      session.stopRunning()
    }
  }

  func capturePhoto() async -> UIImage? {
    guard isRunning else { return nil }

    return await withCheckedContinuation { continuation in
      let delegate = PhotoCaptureDelegate { [weak self] image in
        Task { @MainActor in
          self?.photoDelegate = nil
          continuation.resume(returning: image)
        }
      }
      photoDelegate = delegate

      let settings = AVCapturePhotoSettings()
      sessionQueue.async { [photoOutput] in
        photoOutput.capturePhoto(with: settings, delegate: delegate)
      }
    }
  }

  /// Toggles between 1× and ultra-wide (0.5× when available).
  /// At 1× or above → go to minimum. Below 1× → return to 1×.
  func toggleZoom() {
    let nextZoom: CGFloat = zoomFactor < 1 ? 1 : minZoomFactor
    setZoom(nextZoom, animated: true)
  }

  /// Sets zoom using the display factor (what the label shows).
  func setZoom(_ displayFactor: CGFloat, animated: Bool = false) {
    guard let device else { return }

    let multiplier = max(device.displayVideoZoomFactorMultiplier, 0.0001)
    let videoZoom = displayFactor / multiplier
    let minVideo = device.minAvailableVideoZoomFactor
    let maxVideo = min(device.maxAvailableVideoZoomFactor, device.activeFormat.videoMaxZoomFactor)
    let clampedVideo = min(max(videoZoom, minVideo), maxVideo)
    let clampedDisplay = clampedVideo * multiplier

    guard abs(clampedDisplay - zoomFactor) > 0.001 else { return }

    sessionQueue.async { [weak self] in
      do {
        try device.lockForConfiguration()
        if device.isRampingVideoZoom {
          device.cancelVideoZoomRamp()
        }
        if animated {
          device.ramp(toVideoZoomFactor: clampedVideo, withRate: 8)
        } else {
          device.videoZoomFactor = clampedVideo
        }
        device.unlockForConfiguration()

        Task { @MainActor in
          self?.zoomFactor = clampedDisplay
        }
      } catch {
        Task { @MainActor in
          self?.errorMessage = error.localizedDescription
        }
      }
    }
  }

  private static func requestAccess() async -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      return true
    case .notDetermined:
      return await AVCaptureDevice.requestAccess(for: .video)
    default:
      return false
    }
  }

  private func configureSession() async throws {
    let configuredDevice = try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<AVCaptureDevice, Error>) in
      sessionQueue.async { [session, photoOutput] in
        session.beginConfiguration()
        session.sessionPreset = .photo

        defer { session.commitConfiguration() }

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        // Prefer multi-camera so display zoom can go below 1× (ultra-wide / 0.5×).
        guard let device = Self.bestBackCamera() else {
          continuation.resume(throwing: CameraError.cameraUnavailable)
          return
        }

        do {
          let input = try AVCaptureDeviceInput(device: device)
          guard session.canAddInput(input) else {
            continuation.resume(throwing: CameraError.cannotAddInput)
            return
          }
          session.addInput(input)

          guard session.canAddOutput(photoOutput) else {
            continuation.resume(throwing: CameraError.cannotAddOutput)
            return
          }
          session.addOutput(photoOutput)
          continuation.resume(returning: device)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }

    device = configuredDevice
    syncZoomFromDevice()
  }

  private func startRunningAndApplyDefaultZoom() async throws {
    guard let device else { return }

    let multiplier = max(device.displayVideoZoomFactorMultiplier, 0.0001)
    let videoZoom = 1 / multiplier
    let minVideo = device.minAvailableVideoZoomFactor
    let maxVideo = min(device.maxAvailableVideoZoomFactor, device.activeFormat.videoMaxZoomFactor)
    let clampedVideo = min(max(videoZoom, minVideo), maxVideo)
    let clampedDisplay = clampedVideo * multiplier

    try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<Void, Error>) in
      sessionQueue.async { [session] in
        session.startRunning()

        do {
          try device.lockForConfiguration()
          device.videoZoomFactor = clampedVideo
          device.unlockForConfiguration()

          Task { @MainActor in
            self.zoomFactor = clampedDisplay
            continuation.resume()
          }
        } catch {
          Task { @MainActor in
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }

  private func syncZoomFromDevice() {
    guard let device else { return }
    zoomFactor = device.videoZoomFactor * device.displayVideoZoomFactorMultiplier
  }

  private static func bestBackCamera() -> AVCaptureDevice? {
    if let triple = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
      return triple
    }
    if let dualWide = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
    {
      return dualWide
    }
    return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
  }
}

enum CameraError: LocalizedError {
  case cameraUnavailable
  case cannotAddInput
  case cannotAddOutput

  var errorDescription: String? {
    switch self {
    case .cameraUnavailable:
      return "No camera is available on this device."
    case .cannotAddInput:
      return "Could not connect to the camera."
    case .cannotAddOutput:
      return "Could not set up photo capture."
    }
  }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  private let completion: (UIImage?) -> Void

  init(completion: @escaping (UIImage?) -> Void) {
    self.completion = completion
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    guard
      error == nil,
      let data = photo.fileDataRepresentation(),
      let image = UIImage(data: data)
    else {
      completion(nil)
      return
    }
    completion(image)
  }
}
