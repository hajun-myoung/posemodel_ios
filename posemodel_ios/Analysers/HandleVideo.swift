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
import MLKitPoseDetectionAccurate

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

func testImageGenerator(url: URL) -> UIImage? {
    let asset = AVURLAsset(url: url)
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    
    let cmTime = CMTime(value: 90, timescale: 30)
    let imageRef: CGImage
    
    do {
        imageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
    } catch let error {
        print(error)
        return nil
    }
    
    let uiImage = UIImage(cgImage: imageRef)
    
    return uiImage
}

func AnalyseVideo(url: URL, frames: Int = -1) -> URL?{
    let poseEstimator = PoseEstimator()
//    let poseCanvas = canvas(size: uiImage.size)
//    let poseCanvas = canvas(size: CGSize(width: 1920, height: 1080))

    let asset = AVURLAsset(url: url)
//    var imageList: [UIImage] = []
//    var vImageList: [VisionImage] = []
    
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    
    for currentFrame in 1..<frames {
        let cmTime = CMTime(value: CMTimeValue(currentFrame), timescale: 30)
        let imageRef: CGImage
        
        do {
            imageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print(error)
            return nil
        }
        
        let uiImage = UIImage(cgImage: imageRef)
        let visionImage = VisionImage(image: uiImage)
        
        // vImageList.append(visionImage)
        
        poseEstimator.detectPose(image: visionImage) { results in
            if let poses = results {
                poses.forEach { pose in
                    let targets:[String:PoseLandmarkType] = [
                        "nose": PoseLandmarkType.nose,
                        "leftShoulder": PoseLandmarkType.leftShoulder,
                        "rightShoulder": PoseLandmarkType.rightShoulder,
                        "leftElbow": PoseLandmarkType.leftElbow,
                        "rightElbow": PoseLandmarkType.rightElbow,
                        "leftWrist": PoseLandmarkType.leftWrist,
                        "rightWrist": PoseLandmarkType.rightWrist,
                        "leftHip": PoseLandmarkType.leftHip,
                        "rightHip": PoseLandmarkType.rightHip,
                        "leftKnee": PoseLandmarkType.leftKnee,
                        "rightKnee": PoseLandmarkType.rightKnee,
                        "leftAnkle": PoseLandmarkType.leftAnkle,
                        "rightAnkle": PoseLandmarkType.rightAnkle,
                        "leftHeel": PoseLandmarkType.leftHeel,
                        "rightHeel": PoseLandmarkType.rightHeel,
                        "leftToe": PoseLandmarkType.leftToe,
                        "rightToe": PoseLandmarkType.rightToe,
                    ]

                    for (nodename, node) in targets {
                        let newPoint = CGPoint(
                            x: pose.landmark(ofType: node).position.x,
                            y: pose.landmark(ofType: node).position.y
                        )
                        poseResults[nodename] = newPoint
                    }
                    
                    print(poseResults)
                }
            }
        }
    }
    print("All Images Have Been Converted to VisionImage")
    
//    let resultNodes = poseEstimator.detectPoses(images: vImageList)
    print("The Video is Anlayzed")
//    print(resultNodes)
    
//    print(resultNodes![0])
    return nil
//    let tempDir = NSTemporaryDirectory()
//    let tempURL = URL(fileURLWithPath: tempDir).appendingPathComponent("gaitstudio_resultvideo.mp4")
//    var isSuccess = false
//    
//    createVideo(from: imageList, outputUrl: tempURL) { success in
//        if success {
//            print("Video created successfully.")
//            isSuccess = true
//        } else {
//            print("Failed to create video.")
//        }
//    }
//    
//    if isSuccess {
//        return tempURL
//    }
//    else {
//        return nil
//    }
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
