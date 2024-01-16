//
//  resizing.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/12/24.
//

import Foundation
import UIKit
import VideoToolbox

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: CGPointZero, size: size))
        }
    }
}
