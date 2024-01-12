//
//  ContentView.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import SwiftUI
import UIKit

let testImage:UIImage = UIImage(named: "testimage")!

struct ContentView: View {
    @State var resizedImage:UIImage? = nil
    
    var body: some View {
        VStack {
            Text("Give Image: testImage")
                .font(.system(size: 20, design: .serif))
            
            Image(uiImage: testImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Button {
                resizedImage = testImage.resized(to: CGSize(width: 320, height: 320))
            } label: {
                Label("Resize Image to 320*320", systemImage: "square.arrowtriangle.4.outward")
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
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
