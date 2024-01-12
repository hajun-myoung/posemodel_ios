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
    var body: some View {
        VStack {
            Text("Give Image: testImage")
                .font(.system(size: 20, design: .serif))
            
            Image(uiImage: testImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
