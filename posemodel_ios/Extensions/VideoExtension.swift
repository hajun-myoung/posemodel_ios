import UIKit
import AVFoundation
import Foundation

func createVideo(from images: [String], outputUrl: URL, completion: @escaping (Bool) -> Void) async {
//    let settings = [AVVideoCodecKey: AVVideoCodecType.h264,
//                    AVVideoWidthKey: NSNumber(value: Float(1920)),
//                   AVVideoHeightKey: NSNumber(value: Float(1080))] as [String : Any]
//    let writer = try! AVAssetWriter(outputURL: outputUrl, fileType: .mp4)
//    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
//
//    writer.add(writerInput)
//
//    let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
//
//    writer.startWriting()
//    writer.startSession(atSourceTime: CMTime.zero)
//
//    var frameCount = 0
//    let frameDuration = CMTimeMake(value: 1, timescale: 30)
//    
//    for image in images {
//        let lastFrameTime = CMTimeMake(value: Int64(frameCount), timescale: 30)
//        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
//
//        if let buffer = buffer(from: image) {
//            bufferAdapter.append(buffer, withPresentationTime: presentationTime)
//        }
//
//        frameCount += 1
//    }
//
//    writerInput.markAsFinished()
//    writer.finishWriting {
//        DispatchQueue.main.async {
//            completion(writer.status == .completed)
//        }
//    }
    let filemanager = FileManager.default
    let videoDirectory = filemanager.temporaryDirectory.appending(path: videoFilename)
    let pathComponent = videoDirectory.path
    
    var frameSize: CGSize = CGSize(width: 1920, height: 1080)
    
    var CVPixelBuffers: [CVPixelBuffer] = []
    for (index, image) in images.enumerated() {
        let currentURL = videoDirectory.appending(path: image)
        var uiimage: UIImage
        do {
            let imageData = try Data(contentsOf: currentURL)
            uiimage = UIImage(data: imageData) ?? UIImage()
            frameSize = uiimage.size
            
            guard let buffer = buffer(from: uiimage) else {
                print("Failed to convert UIImage to CVPB")
                print(index, image)
                continue
            }
            
            CVPixelBuffers.append(buffer)
        } catch let error {
            print(error)
        }
    }
    
    let assetWriterSettings = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: frameSize.width,
        AVVideoHeightKey: frameSize.height
    ] as [String : Any]
    
    let settingsAssistant = AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings
    
    do {
        try FileManager.default.removeItem(at: outputUrl)
    } catch {
        print("Could Not Remove File \(error.localizedDescription)")
    }
    
    guard let assetwriter = try? AVAssetWriter(outputURL: outputUrl, fileType: .mov) else {
        abort()
    }
    
    let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
    let assetWriterAdapter = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil
    )
    
    assetwriter.add(assetWriterInput)
    assetwriter.startWriting()
    assetwriter.startSession(atSourceTime: CMTime.zero)
    
    let framesPerSecond = 30
//    let totalFrames = duration * framePerSecond
    var frameCount = 0
    
    while frameCount < CVPixelBuffers.count {
        if assetWriterInput.isReadyForMoreMediaData {
            let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
            assetWriterAdapter.append(CVPixelBuffers[frameCount], withPresentationTime: frameTime)
            frameCount += 1
            print("Video Processing...\(frameCount)")
        }
    }
    
    assetWriterInput.markAsFinished()
    await assetwriter.finishWriting {
        completion(assetwriter.status == .completed)
    }
}
