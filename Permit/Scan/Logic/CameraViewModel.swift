//
//  CameraViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import Combine
import CoreGraphics
import UIKit
import Vision

final class CameraViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var isDetectedFaceValid: Bool
    @Published private(set) var isAcceptableRoll: Bool {
        didSet {
            calculateDetectedFaceValidity()
        }
    }
    
    @Published private(set) var isAcceptablePitch: Bool {
        didSet {
            calculateDetectedFaceValidity()
        }
    }
    
    @Published private(set) var isAcceptableYaw: Bool {
        didSet {
            calculateDetectedFaceValidity()
        }
    }
    
    @Published private(set) var isAcceptableBounds: FaceBoundsState {
        didSet {
            calculateDetectedFaceValidity()
        }
    }
    
    @Published private(set) var isAcceptableQuality: Bool {
        didSet {
            calculateDetectedFaceValidity()
        }
    }
    
    @Published private(set) var faceDetectedState: FaceDetectedState
    @Published private(set) var faceGeometryState: FaceObservation<FaceGeometryModel> {
        didSet {
            processUpdatedFaceGeometry()
        }
    }
    
    @Published private(set) var faceQualityState: FaceObservation<FaceQualityModel> {
        didSet {
            processUpdatedFaceQuality()
        }
    }
    
    let shutterReleased = PassthroughSubject<Void, Never>()
    
    @Published var faceLayoutGuideFrame: CGRect = .zero
    
    @Published var isRecording: Bool = false
    @Published var portraits: [UIImage] = []
    
    let amount: Int
    
    // MARK: - Init
    
    init(amount: Int = 1) {
        self.amount = amount
        faceDetectedState = .noFaceDetected
        isAcceptableRoll = false
        isAcceptablePitch = false
        isAcceptableYaw = false
        isAcceptableBounds = .unknown
        isAcceptableQuality = false
        isDetectedFaceValid = false
        faceGeometryState = .faceNotFound
        faceQualityState = .faceNotFound
    }
    
    // MARK: Perform
    
    func perform(action: CameraAction) {
        switch action {
        case .windowSizeDetected(let frame, let padding):
            handleWindowSizeChanged(toRect: frame, with: padding)
        case .noFaceDetected:
            publishNoFaceObserved()
        case .faceObservationDetected(let observation):
            publishFaceObservation(observation)
        case .faceQualityObservationDetected(let quality):
            publishFaceQualityObservation(quality)
        case .takePhoto:
            takePhoto()
        }
    }
    
    // MARK: Handlers
    
    private func handleWindowSizeChanged(toRect: CGRect, with padding: CGFloat) {
        let side = toRect.width - padding * 2
        faceLayoutGuideFrame = CGRect(x: toRect.midX - side / 2, y: toRect.midY - side / 2, width: side, height: side)
    }
    
    private func publishNoFaceObserved() {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .noFaceDetected
            faceGeometryState = .faceNotFound
            faceQualityState = .faceNotFound
        }
    }
    
    private func publishFaceObservation(_ faceGeometryModel: FaceGeometryModel) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            faceGeometryState = .faceFound(faceGeometryModel)
        }
    }
    
    private func publishFaceQualityObservation(_ faceQualityModel: FaceQualityModel) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            faceQualityState = .faceFound(faceQualityModel)
        }
    }
    
    private func takePhoto() {
        shutterReleased.send()
    }
}

// MARK: Updates

extension CameraViewModel {
    func invalidateFaceGeometryState() {
        isAcceptableRoll = false
        isAcceptablePitch = false
        isAcceptableYaw = false
        isAcceptableBounds = .unknown
    }
    
    func processUpdatedFaceGeometry() {
        switch faceGeometryState {
        case .faceNotFound:
            invalidateFaceGeometryState()
        case .errored(let error):
            invalidateFaceGeometryState()
        case .faceFound(let faceGeometryModel):
            let boundingBox = faceGeometryModel.boundingBox
            let roll = faceGeometryModel.roll.doubleValue
            let pitch = faceGeometryModel.pitch.doubleValue
            let yaw = faceGeometryModel.yaw.doubleValue
            
            updateAcceptableBounds(using: boundingBox)
            updateAcceptableRollPitchYaw(using: roll, pitch: pitch, yaw: yaw)
        }
    }
    
    func updateAcceptableBounds(using boundingBox: CGRect) {
        if boundingBox.width > 1.25 * faceLayoutGuideFrame.width {
            isAcceptableBounds = .detectedFaceTooLarge
        } else if boundingBox.width * 1.25 < faceLayoutGuideFrame.width {
            isAcceptableBounds = .detectedFaceTooSmall
        } else {
            if abs(boundingBox.midX - faceLayoutGuideFrame.midX) > 50 {
                isAcceptableBounds = .detectedFaceOffCentre
            } else if abs(boundingBox.midY - faceLayoutGuideFrame.midY) > 50 {
                isAcceptableBounds = .detectedFaceOffCentre
            } else {
                isAcceptableBounds = .detectedFaceAppropriateSizeAndPosition
            }
        }
    }
    
    func updateAcceptableRollPitchYaw(using roll: Double, pitch: Double, yaw: Double) {
        isAcceptableRoll = roll > 1.2 && roll < 1.6
        isAcceptablePitch = abs(CGFloat(pitch)) < 0.2
        isAcceptableYaw = abs(CGFloat(yaw)) < 0.15
    }
    
    func processUpdatedFaceQuality() {
        switch faceQualityState {
        case .faceNotFound:
            isAcceptableQuality = false
        case .errored(let error):
            isAcceptableQuality = false
        case .faceFound(let model):
            if model.quality < 0.2 {
                isAcceptableQuality = false
            }
            
            isAcceptableQuality = true
        }
    }
    
    func calculateDetectedFaceValidity() {
        isDetectedFaceValid =
        isAcceptableBounds == .detectedFaceAppropriateSizeAndPosition &&
        isAcceptableRoll &&
        isAcceptablePitch &&
        isAcceptableYaw &&
        isAcceptableQuality
    }
}

// MARK: - States

extension CameraViewModel {
    enum CameraAction {
        case windowSizeDetected(CGRect, CGFloat)
        case noFaceDetected
        case faceObservationDetected(FaceGeometryModel)
        case faceQualityObservationDetected(FaceQualityModel)
        case takePhoto
    }
    
    enum FaceDetectedState {
        case faceDetected
        case noFaceDetected
        case faceDetectionErrored
    }
    
    enum FaceBoundsState {
        case unknown
        case detectedFaceTooSmall
        case detectedFaceTooLarge
        case detectedFaceOffCentre
        case detectedFaceAppropriateSizeAndPosition
    }
}
