//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import UIKit
import MLKitVision

let testImage:UIImage = UIImage(named: "test001_02")!

struct ContentView: View {
    @State var isVisionImageConverted: Bool = false
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
                    let vImage = VisionImage(image: testImage)
                    vImage.orientation = testImage.imageOrientation
                    isVisionImageConverted = true
                } label: {
                    Label("Convert to VisionImage", systemImage: "sunglasses")
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                
                if isVisionImageConverted {
                    Text("UIImage has been converted to VisionImage")
                        .font(.system(size: 20, design: .serif))
                }
                else {
                    Text("Not converted, Yet")
                    .font(.system(size: 20, design: .serif))
                }
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
