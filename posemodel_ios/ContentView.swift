//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import UIKit
import MLKitVision
import MLKitPoseDetectionAccurate

let testImage:UIImage = UIImage(named: "test001_02")!
var poseDetector: PoseEstimator? = nil
var vImage: VisionImage? = nil
var poseResults:[String:CGPoint]? = nil

struct ContentView: View {
    @State var isVisionImageConverted: Bool = false
    @State var isModelLoaded: Bool = false
    @State var isPoseDetected: Bool = false
    var body: some View {
        ScrollView{
            VStack {
                Text("Ver. Jan13.1637")
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
                
                Button {
                    poseResults = poseDetector!.detectPose(image: vImage!)
                    
                    if poseResults != nil {
                        isPoseDetected = true
                    }
                } label: {
                    Label("Detect Pose", systemImage: "exclamationmark.magnifyingglass")
                        .font(.system(size: 24, weight: .bold))
                }
                
                if isPoseDetected {
                    Text("Pose Detected")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                } else {
                    Text("No Pose Detected, Yet")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                
                Button {
                    
                } label: {
                    Label("Draw the Pose", systemImage: "exclamationmark.magnifyingglass")
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
