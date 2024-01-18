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
var poseCanvas: canvas? = nil

struct ContentView: View {
    @State var isVisionImageConverted: Bool = false
    @State var isModelLoaded: Bool = false
    @State var isPoseDetected: Bool = false
    @State var resultImage: UIImage? = nil
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
                
                Button {
                    poseDetector!.detectPose(image: vImage!)
                    isPoseDetected = true
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
                    poseCanvas = canvas(size: testImage.size)
                    poseResults = poseDetector!.get_poseresults()
                    
                    var joints: [CGPoint] = []
                    for value in Array(poseResults!.values) {
                        joints.append(value)
                    }
                    resultImage = poseCanvas?.draw_dots(image: testImage, dots: joints)
                } label: {
                    Label("Draw the Pose", systemImage: "exclamationmark.magnifyingglass")
                        .font(.system(size: 24, weight: .bold))
                }
                
                if let resultImage {
                    Image(uiImage: resultImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
