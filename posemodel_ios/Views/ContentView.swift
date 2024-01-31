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
var countedFrames: Int? = 0
let videoURL = Bundle.main.url(forResource: "testvideo", withExtension: "mp4")!
var resultData: Data? = nil

struct ContentView: View {
    @State var isVisionImageConverted: Bool = false
    @State var isModelLoaded: Bool = false
//    @State var isPoseDetected: Bool = false
//    @State var resultImage: UIImage? = nil
    
    // Video Variables
    @State private var player: AVPlayer? = AVPlayer(url: videoURL)
    @State private var testframe: UIImage? = nil
    
    @State private var IGTestingImage: UIImage? = nil
    
    // After Run the Pose Model
    @State private var poseResultData: Data? = nil
    @State private var newImageList: [UIImage] = []
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Ver. Jan17.1807")
                    .font(.system(size: 12, design: .serif))
                    .underline()

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
                
                Button(action: {
                    Task {
                        resultData = await AnalyseVideo(url: videoURL, frames: countedFrames!)
                        if resultData != nil {
                            print("Video Has Been Analyzed")
                        } else {
                            fatalError("No Result Data by Analyse Video Async Function")
                        }
                    }
                }, label: {
                    Label("Analyse Video", systemImage: "figure.run.square.stack.fill")
                        .font(.system(size: 24, weight: .bold))
                })
                .padding()
                
                Button {
                    let imageList: [UIImage] = resultData?.imageList ?? []
                    let jointDict: [[String:CGPoint]] = resultData?.poseResults ?? []
                    
                    var frameSize = CGSize(width: 1920, height: 1080)
                    if !imageList.isEmpty {
                        frameSize = imageList[0].size
                    }
                    
                    let canvas = Canvas(size: frameSize)
                    let postProcessor = PostProcessor()
                    
                    let count = imageList.count
                    
                    /// Start to generate new video(pose model enabled)
                    for i in 0 ..< count {
                        let currentJoints = jointDict[i]
                        let currentDots = Array(currentJoints.values)
                        
                        let newLine = postProcessor.getLines_fromJoints(joints: currentJoints)
                        var newImage = canvas.draw_dots(image: imageList[i], dots: currentDots)
                        newImage = canvas.draw_lines(image: newImage, lines: newLine)
                        
                        newImageList.append(newImage)
                    }
                    
                    print("Succesfully Generate PoseModel Enabled Video")
                } label: {
                    Label("Generate Result Images' List", systemImage: "compass.drawing")
                        .font(.system(size: 24, weight: .bold))
                }
                
//                
//                Button {
//                    let tempDir = NSTemporaryDirectory()
//                    let tempURL = URL(fileURLWithPath: tempDir).appendingPathComponent("gaitstudio_resultvideo.mp4")
//                    var isSuccess = false
//                
//                    createVideo(from: newImageList, outputUrl: tempURL) { success in
//                        if success {
//                            print("Video created successfully.")
//                            isSuccess = true
//                        } else {
//                            print("Failed to create video.")
//                        }
//                    }
//                
//                    if isSuccess {
//                        print(tempURL)
//                    }
//                    else {
//                        fatalError("No Video")
//                    }
//                } label: {
//                    Label("to Video", systemImage: "video.badge.plus")
//                        .font(.system(size: 24, weight: .bold))
//                }
//                
//               
//
                // TODO: Export the Array of UIImage to a Video
                // TODO: Stack the analyzed frames to an Array of UIImage
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
