//
//  Drawing.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/13/24.
//

import Foundation
import UIKit

class Canvas {
    private var frame: UIGraphicsImageRenderer
    
    init(size: CGSize){
        self.frame = UIGraphicsImageRenderer(size: size)
    }
    
    func draw_dots(image: UIImage, dots: [CGPoint], radius:CGFloat = 5) -> UIImage{
        let COLOR_MAX = 255.0
        let red = 52.0, green = 155.0, blue = 235.0
        let red2 = 255.0, green2 = 64.0, blue2 = 70.0
        
        let blueColor = UIColor(
            red: CGFloat(red / COLOR_MAX),
            green: CGFloat(green / COLOR_MAX),
            blue: CGFloat(blue / COLOR_MAX),
            alpha: CGFloat(1)
        )
        
        let renderedImage = frame.image { context in
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
        }
        
        return renderedImage
    }
    
    func draw_lines(image: UIImage, lines: [Line], lineWidth: Double = 3.0) -> UIImage {
        let COLOR_MAX = 255.0
        let red = 52.0, green = 155.0, blue = 235.0
        let red2 = 255.0, green2 = 64.0, blue2 = 70.0
        
        let blueColor = CGColor(
            red: CGFloat(red / COLOR_MAX),
            green: CGFloat(green / COLOR_MAX),
            blue: CGFloat(blue / COLOR_MAX),
            alpha: CGFloat(1)
        )
        
        let renderedImage = frame.image { context in
            image.draw(at: CGPointZero)
            context.cgContext.setStrokeColor(blueColor)
            context.cgContext.setLineWidth(lineWidth)
            
            for line in lines {
                context.cgContext.beginPath()
                context.cgContext.move(to: line.from)
                context.cgContext.addLine(to: line.to)
                context.cgContext.strokePath()
            }
        }
        
        return renderedImage
    }
}
