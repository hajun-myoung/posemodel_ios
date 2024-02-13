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

struct PoseData {
    var imageList: [UIImage]
    var poseResults: [[String:CGPoint]]
}


func URL_to_uiimageList(of url: URL, in endOfFrame: Int) async -> [UIImage] {
    print("Start to convert video -> [UIImage]: \(url), \(endOfFrame)")
    let asset = AVURLAsset(url: url)
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    assetIG.requestedTimeToleranceBefore = .zero
    assetIG.requestedTimeToleranceAfter = .zero
    
    var uiimages: [UIImage] = []
    for frame in 0..<endOfFrame {
        do
        {
            let cmTime = CMTime(value: CMTimeValue(frame), timescale: 30)
            let (image, _) = try await assetIG.image(at: cmTime)
            let uiimage = UIImage(cgImage: image)
            uiimages.append(uiimage)
        } catch let error {
            print("Converting Error: \(error)")
            continue
        }
    }
    
    return uiimages
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

class VideoAnalysisProgress: ObservableObject {
    @Published var progress: Double = 0.0
}

func AnalyseVideo(
    filename: String, url: URL, frames: Int = -1,
    progress: VideoAnalysisProgress
) async -> [[String:CGPoint]]?{
    let poseEstimator = PoseEstimator()

    let asset = AVURLAsset(url: url)
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    assetIG.requestedTimeToleranceBefore = .zero
    assetIG.requestedTimeToleranceAfter = .zero
    
    let filemanager = FileManager.default
    let videoDirectory = filemanager.temporaryDirectory.appending(path: filename)
    let pathComponent = videoDirectory.path
    let isVideoDirectoryExists = filemanager.fileExists(atPath: pathComponent)
    
    if isVideoDirectoryExists {
        do {
            try filemanager.removeItem(at: videoDirectory)
        } catch let error {
            print(error)
        }
    }
    
    do {
        try filemanager.createDirectory(atPath: pathComponent, withIntermediateDirectories: false)
    } catch let error {
        print(error)
    }
    
    var poseResultsArray: [[String:CGPoint]] = []
    for currentFrame in 0..<frames {
        let cmTime = CMTime(value: CMTimeValue(currentFrame), timescale: 30)
        let imageRef: CGImage
        
        do {
            (imageRef, _) = try await assetIG.image(at: cmTime)
        } catch {
            print("[WARN]\tAssetIG.image method error: cannot open error")
            print("\t\tFrames: \(currentFrame)")
            continue
        }
        
        print("[INFO]\tAnalysing Frame Number: #\(currentFrame)")
        DispatchQueue.main.async {
            progress.progress = Double(currentFrame) / Double(frames)
        }
        let uiImage = UIImage(cgImage: imageRef)
        
        // MARK: Saving Frames to use after steps
        if let data = uiImage.pngData() {
            let imageFilename = videoDirectory.appending(path: "\(currentFrame).png")
            do {
                try data.write(to: imageFilename)
            } catch let error {
                print(error)
            }
        }
        
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
    
    return poseResultsArray
}
