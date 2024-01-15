//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import UIKit

let testImage:UIImage = UIImage(named: "test001_02")!
var model:PoseModel? = nil
var pixelBuffer: CVPixelBuffer? = nil
var resultResult: Result? = nil
var resultTimes: Times? = nil
var resultCanvas: canvas? = nil

struct ContentView: View {
    @State var resizedImage:UIImage? = nil
    @State var isPixelbufferConverted:Bool = false
    @State var isModelLoaded:Int = -1
    @State var isAnalyzed:Bool = false
    @State var dottedImage: UIImage? = nil
    
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
                    resizedImage = testImage.resized(to: CGSize(width: 256, height: 256))
                } label: {
                    Label("Resize Image to 256*256", systemImage: "square.arrowtriangle.4.outward")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if let resizedImage {
                    Image(uiImage: resizedImage)
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .padding()
                } else {
                    Text("No Resized Image is Loaded Yet")
                        .font(.system(size: 20, design: .serif))
                        .padding()
                }
                
                Button {
                    pixelBuffer = buffer(from: resizedImage!)
                    isPixelbufferConverted = true
                } label: {
                    Label("Convert to CVPixelBuffer", systemImage: "square.arrowtriangle.4.outward")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if isPixelbufferConverted {
                    Text("State: Converted")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                else {
                    Text("State: Not Converted Yet")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                
                Button {
                    isModelLoaded += 1
                    print("Trying to Model Loading")
                    model = PoseModel()
                    isModelLoaded += 1
                } label: {
                    Label("Load Model", systemImage: "arrow.clockwise")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if isModelLoaded == 1 {
                    Text("Model Has Been Loaded")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                else if isModelLoaded == 0 {
                    Text("Loading...")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                else if isModelLoaded == -1 {
                    Text("Model is Not Loaded Yet")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                else {
                    Text("Unexpected Model Loading State")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                
                Button {
                    let modelResult = model?.runPoseModel(
                        on: pixelBuffer!,
                        from: CGRect(x: 0, y: 0, width: 256, height: 256),
                        to: CGSize(width: 256, height: 256)
                    )
                    
                    resultResult = modelResult?.0
                    resultTimes = modelResult?.1
                    
                    isAnalyzed = true
                } label: {
                    Label("Invoking Model", systemImage: "arrow.clockwise")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if isAnalyzed {
                    Text("Model Has Been Invoked")
                        .font(.system(size: 16, design: .serif))
                        .underline()
                    Text("Times")
                        .font(.system(size: 14, design: .serif))
                    Text("Preprocessing: \(rounddown(number: resultTimes!.preprocessing, deci: 2))ms")
                        .font(.system(size: 12, design: .serif))
                    Text("Inferencing: \(rounddown(number: resultTimes!.inference, deci: 2))ms")
                        .font(.system(size: 12, design: .serif))
                    Text("Postprocessing: \(rounddown(number: resultTimes!.postprocessing, deci: 2))ms")
                        .font(.system(size: 12, design: .serif))
                } else {
                    Text("The Image is not Analyzed Yet")
                        .font(.system(size: 12, design: .serif))
                        .underline()
                }
                
                Button {
                    resultCanvas = canvas(size: CGSize(width: 256, height: 256))
                    dottedImage = resultCanvas?.draw_dots(image: resizedImage!,dots: resultResult!.dots)
                } label: {
                    Label("Draw Dots", systemImage: "arrow.clockwise")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if let dottedImage {
                    Image(uiImage: dottedImage)
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .padding()
                    } else {
                        Text("No Dotted Image is Loaded Yet")
                            .font(.system(size: 20, design: .serif))
                            .padding()
                    }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
