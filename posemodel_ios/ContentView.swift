//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import UIKit

let testImage:UIImage = UIImage(named: "test001_02")!
var pixelBuffer: CVPixelBuffer? = nil

struct ContentView: View {
    @State var resizedImage:UIImage? = nil
    @State var isPixelbufferConverted:Bool = false
    
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
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
