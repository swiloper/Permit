//
//  FaceDetector.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import AVFoundation
import Combine
import UIKit
import Vision

protocol FaceDetectorDelegate: NSObjectProtocol {
    func convertFromMetadataToPreviewRect(rect: CGRect) -> CGRect
    func draw(image: CIImage)
}

final class FaceDetector: NSObject {
    weak var viewDelegate: FaceDetectorDelegate?
    weak var model: CameraViewModel? {
        didSet {
            model?.shutterReleased.sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { _ in
                self.isCapturingPhoto = true
            }
            .store(in: &subscriptions)
        }
    }
    
    var sequenceHandler = VNSequenceRequestHandler()
    var isCapturingPhoto = false
    var currentFrameBuffer: CVImageBuffer?
    
    var subscriptions = Set<AnyCancellable>()
    
    let imageProcessingQueue = DispatchQueue(
        label: "Image Processing Queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension FaceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if isCapturingPhoto {
            isCapturingPhoto = false
            savePortrait(from: imageBuffer)
        }
        
        let detectFaceRectanglesRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFaceRectangles)
        detectFaceRectanglesRequest.revision = VNDetectFaceRectanglesRequestRevision3
        
        let detectCaptureQualityRequest = VNDetectFaceCaptureQualityRequest(completionHandler: detectedFaceQualityRequest)
        detectCaptureQualityRequest.revision = VNDetectFaceCaptureQualityRequestRevision2
        
        let detectSegmentationRequest = VNGeneratePersonSegmentationRequest(completionHandler: detectedSegmentationRequest)
        detectSegmentationRequest.qualityLevel = .balanced
        
        currentFrameBuffer = imageBuffer
        
        do {
            try sequenceHandler.perform(
                [detectFaceRectanglesRequest, detectCaptureQualityRequest, detectSegmentationRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Methods

extension FaceDetector {
    func detectedFaceRectangles(request: VNRequest, error: Error?) {
        guard let model = model, let viewDelegate = viewDelegate else { return }
        
        guard let results = request.results as? [VNFaceObservation], let result = results.first else {
            model.perform(action: .noFaceDetected)
            return
        }
        
        let convertedBoundingBox = viewDelegate.convertFromMetadataToPreviewRect(rect: result.boundingBox)
        
        let faceObservationModel = FaceGeometryModel(
            boundingBox: convertedBoundingBox,
            roll: result.roll ?? 0,
            pitch: result.pitch ?? 0,
            yaw: result.yaw ?? 0
        )
        
        model.perform(action: .faceObservationDetected(faceObservationModel))
    }
    
    // MARK: - Quality
    
    func detectedFaceQualityRequest(request: VNRequest, error: Error?) {
        guard let model else { return }
        
        guard let results = request.results as? [VNFaceObservation], let first = results.first else {
            model.perform(action: .noFaceDetected)
            return
        }
        
        let faceQualityModel = FaceQualityModel(quality: first.faceCaptureQuality ?? .zero)
        model.perform(action: .faceQualityObservationDetected(faceQualityModel))
    }
    
    // MARK: - Segmentation
    
    func detectedSegmentationRequest(request: VNRequest, error: Error?) {
        guard let currentFrameBuffer = currentFrameBuffer else { return }
        let originalImage = CIImage(cvImageBuffer: currentFrameBuffer).oriented(.upMirrored)
        viewDelegate?.draw(image: originalImage)
    }
    
    // MARK: - Save
    
    func savePortrait(from pixelBuffer: CVPixelBuffer) {
        guard let model else { return }
        
        imageProcessingQueue.async {
            let originalImage = CIImage(cvPixelBuffer: pixelBuffer)
            let outputImage = originalImage
            
            let coef = outputImage.extent.width / UIScreen.main.bounds.width
            let side = coef * model.faceLayoutGuideFrame.width
            
            let photoRect = CGRect(x: (outputImage.extent.width - side) / 2, y: (outputImage.extent.height - side) / 2, width: side, height: side)
            
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: photoRect) {
                var photo = UIImage(cgImage: cgImage, scale: 1, orientation: .upMirrored)
                
                if let resized = self.resizeImage(image: photo, targetSize: CGSize(width: 180, height: 180)) {
                    photo = resized
                }
                
                model.portraits.append(photo)
                
//                DispatchQueue.main.async {
//                    model.perform(action: .savePhoto(photo))
//                }
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below.
        let rect = CGRect(origin: .zero, size: CGSize(width: newSize.width, height: newSize.height))
        
        // Actually do the resizing to the rect using the ImageContext stuff.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
