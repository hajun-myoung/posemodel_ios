//
//  Drawing.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/13/24.
//

import Foundation
import UIKit

func draw_pose(image: UIImage, dots: [CGPoint], lines: [Line], radius:CGFloat = 5, index:Int? = -1){
    defer {
        UIGraphicsEndImageContext()
    }
    
    
    let filemanager = FileManager.default
    let videoDirectory = filemanager.temporaryDirectory.appending(path: videoFilename)
    
    let COLOR_MAX = 255.0
    let red = 52.0, green = 155.0, blue = 235.0
    
    let blueColor = UIColor(
        red: CGFloat(red / COLOR_MAX),
        green: CGFloat(green / COLOR_MAX),
        blue: CGFloat(blue / COLOR_MAX),
        alpha: CGFloat(1)
    )
    
    let lineWidth: Double = 3.0
//    guard let context = UIGraphicsGetCurrentContext() else {
//        return
//    }
    
    let bound = CGRect(origin: .zero, size: image.size)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let image = UIGraphicsImageRenderer(bounds: bound, format: format).image { context in
        image.draw(at: CGPointZero)
        blueColor.setFill()
        for dot in dots {
            let rect = CGRect(
                x: dot.x - radius, y: dot.y - radius,
                width: 2 * radius, height: 2 * radius
            )
            context.cgContext.fillEllipse(in: rect)
        }
        
        blueColor.setStroke()
        for dot in dots {
            let radius = radius * 1.5
            let rect = CGRect(
                x: dot.x - radius, y: dot.y - radius,
                width: 2 * radius, height: 2 * radius
            )
            context.cgContext.strokeEllipse(in: rect)
        }
        
        context.cgContext.setLineWidth(lineWidth)
        for line in lines {
            context.cgContext.beginPath()
            context.cgContext.move(to: line.from)
            context.cgContext.addLine(to: line.to)
            context.cgContext.strokePath()
        }
    }
    
    if let newData = image.pngData() {
        if let index {
            var indexString: String!
            if index < 10 {
                indexString = "00\(index)"
            } else if index < 100 {
                indexString = "0\(index)"
            } else {
                indexString = "\(index)"
            }
            
            var imageFilename: URL
            if let indexString {
                imageFilename = videoDirectory.appending(path: "pose_\(indexString).png")
                
                do {
                    try newData.write(to: imageFilename)
                } catch let error {
                    print(error)
                }
            }
        }
    }

    if let index {
        print(index, "done")
    }
    
    return
}
