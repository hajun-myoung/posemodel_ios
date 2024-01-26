//
//  HandleVideo.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/24/24.
//

import Foundation
import UIKit
import AVFoundation
import MLKitVision

func GetFrames_fromVideo(url: URL) async -> Int?{
    let asset = AVURLAsset(url: url)
    var nFrames = 0
    do{
        let reader = try AVAssetReader(asset: asset)
        let videoTrack = try await asset.loadTracks(withMediaType: AVMediaType.video)[0]
        
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
        
        reader.add(readerOutput)
        reader.startReading()
        
        while true {
            var sampleBuffer = readerOutput.copyNextSampleBuffer()
            if sampleBuffer ==  nil {
                break
            }
            nFrames += 1
        }
        print("Num frames: \(nFrames)")
    } catch let error {
        print(error)
        return nil
    }
    
    return nFrames
}

func AnalyseVideo(url: URL, frames: Int = -1) async -> URL?{
    let poseEstimator = PoseEstimator()
    let asset = AVURLAsset(url: url)
    var imageList: [UIImage] = []
    
    
    do{
        let reader = try AVAssetReader(asset: asset)
        let videoTrack = try await asset.loadTracks(withMediaType: AVMediaType.video)[0]
        
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
        
        reader.add(readerOutput)
        reader.startReading()
        
        var currentFrame = 1
        while true {
            let percentage = Double(currentFrame) / Double(frames) * 100
            print("\(percentage)% (\(currentFrame)/\(frames)", terminator: "\r")
            
            let sampleBuffer = readerOutput.copyNextSampleBuffer()
            
            if sampleBuffer ==  nil {
                break
            } else {
                let visionImage = VisionImage(buffer: sampleBuffer!)
                poseEstimator.detectPose(image: visionImage)
                let lines = poseEstimator.get_lines()
                let dots = poseEstimator.get_dots()
                
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
                let uiimage = UIImage(pixelBuffer: imageBuffer!)
                
                let poseCanvas = canvas(size: uiimage!.size)
                
                var resultImage = poseCanvas.draw_dots(image: uiimage!, dots: dots)
                resultImage = poseCanvas.draw_lines(image: resultImage, lines: lines)
                
                imageList.append(resultImage)
            }
            
            currentFrame += 1
        }
    } catch let error {
        print(error)
        return nil
    }
    
    let tempDir = NSTemporaryDirectory()
    let tempURL = URL(fileURLWithPath: tempDir).appendingPathComponent("gaitstudio_resultvideo.mp4")
    var isSuccess = false
    
    createVideo(from: imageList, outputUrl: tempURL) { success in
        if success {
            print("Video created successfully.")
            isSuccess = true
        } else {
            print("Failed to create video.")
        }
    }
    
    if isSuccess {
        return tempURL
    }
    else {
        return nil
    }
}

//class VideoAnalyzer{
//    private var asset: AVAsset
//    private var reader: AVAssetReader
//    var imageList: [UIImage]
//    
//    /// Status Index
//    /// 0   Initailized
//    /// 1   Analyzing
//    /// 2   Analyzed
//    /// 3   Analyzing Failed
//    /// 4   Other(Unexpected)
//    var status = 0
//    
//    init(url: URL){
//        do {
//            self.asset = AVURLAsset(url: url)
//            self.reader = try AVAssetReader(asset: asset)
//            self.imageList = []
//        } catch let error {
//            fatalError("Initializing Error: \(error)")
//        }
//    }
//}
