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

    private(set) var isRunning = false
    private(set) var zoomFactor: CGFloat = 1
    var errorMessage: String?

    var zoomLabel: String {
        String(format: "%.0fx", zoomFactor)
    }

    func start() async {
        let authorized = await Self.requestAccess()
        guard authorized else {
            errorMessage = "Camera access was denied."
            return
        }

        do {
            try await configureSession()
            sessionQueue.async { [session] in
                session.startRunning()
            }
            isRunning = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            guard session.isRunning else { return }
            session.stopRunning()
        }
        isRunning = false
    }

    func capturePhoto() async -> UIImage? {
        guard isRunning else { return nil }

        return await withCheckedContinuation { continuation in
            let delegate = PhotoCaptureDelegate { [weak self] image in
                self?.photoDelegate = nil
                continuation.resume(returning: image)
            }
            photoDelegate = delegate

            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

    func toggleZoom() {
        guard let device else { return }

        let nextZoom: CGFloat
        switch zoomFactor {
        case ..<1.5:
            nextZoom = min(2, device.activeFormat.videoMaxZoomFactor)
        case ..<2.5:
            nextZoom = min(3, device.activeFormat.videoMaxZoomFactor)
        default:
            nextZoom = 1
        }

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = nextZoom
            device.unlockForConfiguration()
            zoomFactor = nextZoom
        } catch {
            errorMessage = error.localizedDescription
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
        let configuredDevice = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AVCaptureDevice, Error>) in
            sessionQueue.async { [session, photoOutput] in
                session.beginConfiguration()
                session.sessionPreset = .photo

                defer { session.commitConfiguration() }

                session.inputs.forEach { session.removeInput($0) }
                session.outputs.forEach { session.removeOutput($0) }

                guard
                    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                else {
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
        zoomFactor = configuredDevice.videoZoomFactor
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
