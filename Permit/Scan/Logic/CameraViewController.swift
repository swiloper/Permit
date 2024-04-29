//
//  CameraViewController.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import AVFoundation
import CoreImage
import MetalKit

final class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    var faceDetector: FaceDetector?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let session = AVCaptureSession()
    
    var isUsingMetal = false
    var metalDevice: MTLDevice?
    var metalCommandQueue: MTLCommandQueue?
    var metalView: MTKView?
    var ciContext: CIContext?
    
    var currentCIImage: CIImage? {
        didSet {
            metalView?.draw()
        }
    }
    
    let videoOutputQueue = DispatchQueue(
        label: "Video Output Queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    // MARK: - Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faceDetector?.viewDelegate = self
        configureMetal()
        configureCaptureSession()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
}

// MARK: - Capture

extension CameraViewController {
    func configureCaptureSession() {
        // Define the capture device we want to use.
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            fatalError("No front video camera available.")
        }
        
        // Connect the camera to the capture session input.
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            session.addInput(input)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output.
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(faceDetector, queue: videoOutputQueue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session.
        session.addOutput(output)
        
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        // Configure the preview layer.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspect
        previewLayer?.frame = view.bounds
        
        if !isUsingMetal, let previewLayer {
            view.layer.insertSublayer(previewLayer, at: .zero)
        }
    }
}

// MARK: Metal

extension CameraViewController {
    func configureMetal() {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not instantiate required metal properties.")
        }
        
        isUsingMetal = true
        metalCommandQueue = metalDevice.makeCommandQueue()
        
        metalView = MTKView()
        
        if let metalView {
            metalView.device = metalDevice
            metalView.isPaused = true
            metalView.enableSetNeedsDisplay = false
            metalView.delegate = self
            metalView.framebufferOnly = false
            metalView.frame = view.bounds
            metalView.layer.contentsGravity = .resizeAspect
            view.layer.insertSublayer(metalView.layer, at: .zero)
        }
        
        ciContext = CIContext(mtlDevice: metalDevice)
    }
}

// MARK: - MTKViewDelegate

extension CameraViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let metalView, let metalCommandQueue else { return }
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else { return }
        guard let ciImage = currentCIImage else { return }
        guard let currentDrawable = view.currentDrawable else { return }
        
        // Make sure the image is full width, and scaled in height appropriately.
        let drawSize = metalView.drawableSize
        let scaleX = drawSize.width / ciImage.extent.width
        let newImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleX))
        let originY = (newImage.extent.height - drawSize.height) / 2
        
        // Render into the metal texture.
        ciContext?.render(
            newImage,
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: CGRect(x: .zero, y: originY, width: newImage.extent.width, height: newImage.extent.height),
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        
        // Register drawwable to command buffer.
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Nothing to update.
    }
}

// MARK: FaceDetectorDelegate

extension CameraViewController: FaceDetectorDelegate {
    func convertFromMetadataToPreviewRect(rect: CGRect) -> CGRect {
        guard let previewLayer else { return .zero }
        return previewLayer.layerRectConverted(fromMetadataOutputRect: rect)
    }
    
    func draw(image: CIImage) {
        currentCIImage = image
    }
}
