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
import Foundation

let testImage:UIImage = UIImage(named: "test001_02")!
var poseDetector: PoseEstimator? = nil
var vImage: VisionImage? = nil
var poseResults:[String:CGPoint] = [:]
var countedFrames: Int? = 0

let videoFilename = "IMG_0460"
let videoExtension = "mov"
//let videoFilename = "testvideo"
let videoURL = Bundle.main.url(forResource: videoFilename, withExtension: videoExtension)!

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
    @State private var poseResultData: PoseData? = nil
    @State private var newImageList: [UIImage] = []
    @State private var resultData: [[String:CGPoint]]? = nil
    
    @State private var resultVideoURL: URL!
    @State private var isSuccess = false
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Ver. Feb6.1637")
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
                        resultData = await AnalyseVideo(filename: videoFilename, url: videoURL, frames: countedFrames!)
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
                
                if let resultData {
                    let headers = [
                        "nose", "rightElbow", "leftElbow", "leftKnee", "leftWrist", "rightToe", "rightHeel", "rightAnkle", "rightWrist", "leftShoulder", "leftHeel", "rightKnee", "leftAnkle", "rightShoulder", "leftHip", "leftToe", "rightHip"
                    ]
                    
                    ShareLink(item: createCSV(for: headers, of: resultData)) {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                }
                
                
                Button(action:{
                    Task {
                        var imageList: [String] = []
//                        imageList = await URL_to_uiimageList(of: videoURL, in: countedFrames!)
                        let jointDict: [[String:CGPoint]] = resultData ?? []
                        let postProcessor = PostProcessor()
                        
                        let filemanager = FileManager.default
                        let videoDirectory = filemanager.temporaryDirectory.appending(path: videoFilename)
                        let pathComponent = videoDirectory.path
                        
                        do {
                            imageList = try filemanager.contentsOfDirectory(atPath: pathComponent)
                        } catch let error {
                            print(error)
                        }
                        
                        let count = imageList.count
                        
                        // Start to generate new video(pose model enabled)
                        for imageName in imageList {
                            print(imageName)
//                            let canvas = Canvas(size: frameSize)
//                            let currentJoints: [String:CGPoint] = jointDict[i]
                            let currentImageURL = videoDirectory.appending(path: imageName)
                            var currentImageData: Data? = try Data(contentsOf: currentImageURL)
                            var currentImage: UIImage? = UIImage(data: currentImageData!)!
                            let index = Int(imageName.components(separatedBy: ".")[0])
                            
                            var currentJoints: [String:CGPoint] = [:]
                            if index! > resultData!.count {
                                print("No Joints")
                            } else {
                                currentJoints = resultData![index!]
                                let currentDots = Array(currentJoints.values)
                                let currentLines = postProcessor.getLines_fromJoints(joints: currentJoints)
                                
                                draw_dots(image: currentImage!, dots: currentDots, index: index!)

//                                newImage = canvas.draw_lines(image: newImage!, lines: newLine)
//                                print(newImage)
//                                newImageList.append(newImage)
                                
//                                if newImage.size == CGSize(width: 0, height: 0) {
//                                    print("Image Error: #\(String(describing: index))")
//                                } else {
//                                    print("Image Processed: #\(String(describing: index))")
//                                }
                            }
                            
                            
                        }
                        
//                        imageList = []
                        print("Succesfully Generate PoseModel Enabled Video")
                    }
                }
                ,label: {
                    Label("Generate Result Images' List", systemImage: "compass.drawing")
                        .font(.system(size: 24, weight: .bold))
                })
                .padding()
                
                Button (action: {
                    Task {
                        do {
                            let path = try FileManager.default.url(
                                for: .documentDirectory,
                                in: .allDomainsMask,
                                appropriateFor: nil,
                                create: false
                            )
                            
                            resultVideoURL = path.appendingPathComponent("gait-result.mp4")
                            print("New Result Video URL: \(resultVideoURL)")
                            
                            await createVideo(
                                from: newImageList, outputUrl: resultVideoURL
                            ) { success in
                                if success {
                                    print("Video created successfully.")
                                    isSuccess = true
                                } else {
                                    print("Failed to create video.")
                                }
                            }
                            
                            newImageList = []
                        } catch {
                            print("Button Error")
                        }
                    }
                }, label: {
                    Label("to Video", systemImage: "video.badge.plus")
                        .font(.system(size: 24, weight: .bold))
                })
                
                if isSuccess {
                    Text("New Video Ready")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                    VideoPlayer(
                        player: AVPlayer(
                            url: resultVideoURL
                        )
                    )
                    .aspectRatio(contentMode: .fit)
                }

                
                // TODO: Export the Array of UIImage to a Video
                // TODO: Stack the analyzed frames to an Array of UIImage
            }
            .padding()
            
            
            if let resultVideoURL {
                VideoPlayer(player: AVPlayer(url: resultVideoURL))
                .padding()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
