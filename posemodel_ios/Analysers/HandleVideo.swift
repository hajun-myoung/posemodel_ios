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

struct Data {
    var imageList: [UIImage]
    var poseResults: [[String:CGPoint]]
}

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
            let sampleBuffer = readerOutput.copyNextSampleBuffer()
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

func AnalyseVideo(url: URL, frames: Int = -1) async -> Data?{
    let poseEstimator = PoseEstimator()

    let asset = AVURLAsset(url: url)
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    
    var imageList: [UIImage] = []
    var poseResultsArray: [[String:CGPoint]] = []
    for currentFrame in 1..<frames + 1 {
        let cmTime = CMTime(value: CMTimeValue(currentFrame), timescale: 30)
        let imageRef: CGImage
        
        do {
            imageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print(error)
            return nil
        }
        
        let uiImage = UIImage(cgImage: imageRef)
//        imageList.append(uiImage)
        
        let visionImage = VisionImage(image: uiImage)
        
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
                    poseResultsArray.append(poseResults)
                }
            }
        }
    }
    let returnData = Data(imageList: [], poseResults: poseResultsArray)
    
    return returnData
}
