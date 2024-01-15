//
//  Drawing.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/13/24.
//

import Foundation
import UIKit

class canvas {
    private var frame: UIGraphicsImageRenderer
    
    init(size: CGSize){
        self.frame = UIGraphicsImageRenderer(size: size)
    }
    
    func draw_dots(image: UIImage, dots: [CGPoint], radius:CGFloat = 2) -> UIImage{
        let COLOR_MAX = 255
        let red = 255, green = 165, blue = 0

        let myColor = UIColor(
            red: CGFloat(red / COLOR_MAX),
            green: CGFloat(green / COLOR_MAX),
            blue: CGFloat(blue / COLOR_MAX),
            alpha: CGFloat(1)
        )
        
        let renderedImage = frame.image { context in
            image.draw(at: CGPointZero)
            myColor.setFill()
            
            for dot in dots {
                print(dot)
                let rect = CGRect(
                    x: dot.x - radius, y: dot.y - radius,
                    width: 2 * radius, height: 2 * radius
                )
                context.cgContext.fillEllipse(in: rect)
            }
        }
        
        return renderedImage
    }
}
