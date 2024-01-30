//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import MLKitVision
import MLKitPoseDetectionAccurate
import AVKit

let testImage:UIImage = UIImage(named: "test001_02")!
var poseDetector: PoseEstimator? = nil
var vImage: VisionImage? = nil
var poseResults:[String:CGPoint] = [:]
var poseCanvas: canvas? = nil
var countedFrames: Int? = 0
let videoURL = Bundle.main.url(forResource: "testvideo", withExtension: "mp4")!

struct ContentView: View {
    @State var isVisionImageConverted: Bool = false
    @State var isModelLoaded: Bool = false
//    @State var isPoseDetected: Bool = false
//    @State var resultImage: UIImage? = nil
    
    // Video Variables
    @State private var player: AVPlayer? = AVPlayer(url: videoURL)
    @State private var testframe: UIImage? = nil
    
    @State private var IGTestingImage: UIImage? = nil
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Ver. Jan17.1807")
                    .font(.system(size: 12, design: .serif))
                    .underline()
                
                Text("Given Image: testImage")
                    .font(.system(size: 20, design: .serif))
                    .underline()
                
                Image(uiImage: testImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Button {
                    poseDetector = PoseEstimator()
                    isModelLoaded = true
                } label: {
                    Label("Load Model", systemImage: "arrow.down.app.fill")
                        .font(.system(size: 24, weight: .bold))
                }
                
                if isModelLoaded {
                    Text("The Model is Successfully Loaded")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                else {
                    Text("Model is not Loaded")
                    .font(.system(size: 20, design: .serif))
                    .padding()
                }
                
                Button {
                    vImage = VisionImage(image: testImage)
                    vImage!.orientation = testImage.imageOrientation
                    isVisionImageConverted = true
                } label: {
                    Label("Convert to VisionImage", systemImage: "sunglasses")
                        .font(.system(size: 24, weight: .bold))
                }
                
                if isVisionImageConverted {
                    Text("UIImage has been converted to VisionImage")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                else {
                    Text("Not converted, Yet")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                
//                Button {
//                    poseDetector!.detectPose(image: vImage!)
//                 // poseDetector!.detectPose(image: testImage)
//                    isPoseDetected = true
//                } label: {
//                    Label("Detect Pose", systemImage: "exclamationmark.magnifyingglass")
//                        .font(.system(size: 24, weight: .bold))
//                }
//                
//                if isPoseDetected {
//                    Text("Pose Detected")
//                        .font(.system(size: 20, design: .serif))
//                        .padding()
//                } else {
//                    Text("No Pose Detected, Yet")
//                        .font(.system(size: 20, design: .serif))
//                        .padding()
//                }
                
//                Button {
//                    poseCanvas = canvas(size: testImage.size)
//                    poseResults = poseDetector!.get_poseresults()
//                    
//                    var joints: [CGPoint] = []
//                    for value in Array(poseResults!.values) {
//                        joints.append(value)
//                    }
//                    
//                    // Draw the dots
//                    resultImage = poseCanvas?.draw_dots(image: testImage, dots: joints)
//                    // Draw the lines
//                    let lines = poseDetector!.get_lines()
//                    resultImage = poseCanvas?.draw_lines(image: resultImage!, lines: lines)
//                } label: {
//                    Label("Draw the Pose", systemImage: "hand.draw.fill")
//                        .font(.system(size: 24, weight: .bold))
//                }
//                .padding()
                
//                if let resultImage {
//                    Image(uiImage: resultImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                }
//                
//                
//                Button {
//                    IGTestingImage = testImageGenerator(url: videoURL)
////                    let results = poseDetector!.detectPose(image: IGTestingImage!)
//                    let visionImage = VisionImage(image: IGTestingImage!)
//                    poseDetector!.detectPose(image: visionImage) { results in
//                        if let poses = results {
//                            poses.forEach { pose in
//                                let targets:[String:PoseLandmarkType] = [
//                                    "nose": PoseLandmarkType.nose,
//                                    "leftShoulder": PoseLandmarkType.leftShoulder,
//                                    "rightShoulder": PoseLandmarkType.rightShoulder,
//                                    "leftElbow": PoseLandmarkType.leftElbow,
//                                    "rightElbow": PoseLandmarkType.rightElbow,
//                                    "leftWrist": PoseLandmarkType.leftWrist,
//                                    "rightWrist": PoseLandmarkType.rightWrist,
//                                    "leftHip": PoseLandmarkType.leftHip,
//                                    "rightHip": PoseLandmarkType.rightHip,
//                                    "leftKnee": PoseLandmarkType.leftKnee,
//                                    "rightKnee": PoseLandmarkType.rightKnee,
//                                    "leftAnkle": PoseLandmarkType.leftAnkle,
//                                    "rightAnkle": PoseLandmarkType.rightAnkle,
//                                    "leftHeel": PoseLandmarkType.leftHeel,
//                                    "rightHeel": PoseLandmarkType.rightHeel,
//                                    "leftToe": PoseLandmarkType.leftToe,
//                                    "rightToe": PoseLandmarkType.rightToe,
//                                ]
//                
//                                for (nodename, node) in targets {
//                                    let newPoint = CGPoint(
//                                        x: pose.landmark(ofType: node).position.x,
//                                        y: pose.landmark(ofType: node).position.y
//                                    )
//                                    poseResults[nodename] = newPoint
//                                }
//                                print(poseResults)
//                            }
//                        } else {
//                            print("NO POSES")
//                        }
//                    }
//                    print("Detected!")
//                } label: {
//                    Label("Test Image Generator", systemImage: "exclamationmark.circle")
//                        .font(.system(size: 24, weight: .bold))
//                }
                
//                if let IGTestingImage {
//                    Image(uiImage: IGTestingImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding()
//                }
//                
                if let player {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("No Video Loaded")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                
                Button(action: {
                    Task {
                        countedFrames = await GetFrames_fromVideo(url: videoURL)
                    }
                }, label: {
                    Label("Count Frames of the Video", systemImage: "video.fill.badge.checkmark")
                        .font(.system(size: 24, weight: .bold))
                })
                .padding()
                
//                if let testframe {
//                    Image(uiImage: testframe)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding()
//                } else {
//                    Text("No Frames Extracted")
//                        .font(.system(size: 20, design: .serif))
//                        .padding()
//                }
                
                Button(action: {
                    Task {
                        let resultURL = await AnalyseVideo(url: videoURL, frames: countedFrames!)
                        print(resultURL ?? "NO URL")
                    }
                }, label: {
                    Label("Analyse Video", systemImage: "figure.run.square.stack.fill")
                        .font(.system(size: 24, weight: .bold))
                })
                .padding()
                
                // TODO: Analyse the frames with PoseModel
                // TODO: Stack the analyzed frames to an Array of UIImage
                // TODO: Export the Array of UIImage to a Video
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
