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
    
    // Video Variables
    @State private var player: AVPlayer? = AVPlayer(url: videoURL)
    @State private var testframe: UIImage? = nil
    
    @State private var IGTestingImage: UIImage? = nil
    
    // After Run the Pose Model
    @State private var poseResultData: PoseData? = nil
    @State private var resultData: [[String:CGPoint]]? = nil
    
    @State private var resultVideoURL: URL!
    @State private var isSuccess = false
    
    @State private var statusText = "Analyzing Not Started"
    @StateObject var videoProgress = VideoAnalysisProgress()
    @State private var statusCode: Int = 0

    var body: some View {
        ScrollView{
            VStack {
                Text("Ver. Feb13.2251")
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
                
                Text(statusText)
                    .font(.system(size: 20, design: .serif))
                    .padding()
                
                Button(action: {
                    Task {
                        /// Counting Frames for the Loop Statement
                        statusText = "Ready for Analyzing"
                        countedFrames = await GetFrames_fromVideo(url: videoURL)
                        
                        statusText = "Analayzing..."
                        statusCode = 1
                        resultData = await AnalyseVideo(
                            filename: videoFilename, url: videoURL, frames: countedFrames!,
                            progress: videoProgress
                        )
                        statusCode = 0
                        
                        if resultData != nil {
                            statusText = "Video Has Been Analyzed"
                        } else {
                            statusText = "No Result Data by Analyse Video Async Function"
                            return
                        }
                        
                        statusText = "Getting Directory Structure"
                        /// Drawing Poses
                        var imageList: [String] = []

                        let filemanager = FileManager.default
                        let videoDirectory = filemanager.temporaryDirectory.appending(path: videoFilename)
                        let pathComponent = videoDirectory.path

                        do {
                            imageList = try filemanager.contentsOfDirectory(atPath: pathComponent)
                        } catch let error {
                            print(error)
                        }


                        // Start to generate new video(pose model enabled)
                        statusText = "Drawing Poses..."
                        videoProgress.progress = 0.0
                        drawing_main(
                            imageList: imageList, videoDirectory: videoDirectory,
                            resultData: resultData!
                        )
                        
                        var analyzedImagesName: [String] = []
                        do {
                            let files: [String] = try filemanager.contentsOfDirectory(atPath: pathComponent)
                            for curFile in files {
                                if curFile.starts(with: "pose_") {
                                    analyzedImagesName.append(curFile)
                                }
                            }

                            analyzedImagesName.sort()
                        } catch let error {
                            print(error)
                        }

                        do {
                            let path = try filemanager.url(
                                for: .documentDirectory,
                                in: .allDomainsMask,
                                appropriateFor: nil,
                                create: false
                            )

                            resultVideoURL = path.appendingPathComponent("\(videoFilename)_analyzed.mp4")
                            if let resultVideoURL {
                                print("Result Video URL: \(resultVideoURL)")
                                print("Files: ", analyzedImagesName)
                            }

                            await createVideo(
                                from: analyzedImagesName, outputUrl: resultVideoURL
                            ) { success in
                                if success {
                                    print("Video created successfully.")
                                    isSuccess = true
                                } else {
                                    print("Failed to create video.")
                                }
                            }
                        } catch {
                            print("Button Error")
                        }
                    }
                }, label: {
                    Label("Start Analyzing", systemImage: "video.fill.badge.checkmark")
                        .font(.system(size: 24, weight: .bold))
                })
                
                if statusCode == 1 {
                    ProgressView(value: videoProgress.progress)
                        .padding()
                }
                
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

                if let resultData {
                    let headers = [
                        "nose", "rightElbow", "leftElbow", "leftKnee", "leftWrist", "rightToe", "rightHeel", "rightAnkle", "rightWrist", "leftShoulder", "leftHeel", "rightKnee", "leftAnkle", "rightShoulder", "leftHip", "leftToe", "rightHip"
                    ]
                    
                    let csvURL = createCSV(for: headers, of: resultData, filename: videoFilename)

                    ShareLink(item: csvURL) {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                }
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
