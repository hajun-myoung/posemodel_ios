import UIKit
import AVFoundation

func createVideo(from images: [UIImage], outputUrl: URL, completion: @escaping (Bool) -> Void) {
    let settings = [AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: NSNumber(value: Float(1920)),
                   AVVideoHeightKey: NSNumber(value: Float(1080))] as [String : Any]
    let writer = try! AVAssetWriter(outputURL: outputUrl, fileType: .mp4)
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)

    writer.add(writerInput)

    let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)

    writer.startWriting()
    writer.startSession(atSourceTime: CMTime.zero)

    var frameCount = 0
    let frameDuration = CMTimeMake(value: 1, timescale: 30)
    
    for image in images {
        let lastFrameTime = CMTimeMake(value: Int64(frameCount), timescale: 30)
        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)

        if let buffer = buffer(from: image) {
            bufferAdapter.append(buffer, withPresentationTime: presentationTime)
        }

        frameCount += 1
    }

    writerInput.markAsFinished()
    writer.finishWriting {
        DispatchQueue.main.async {
            completion(writer.status == .completed)
        }
    }
}
