//
//  ModelLoader.swift
//  posemodeltest
//
//  Created by 명하준 on 12/29/23.
//  All comments wrote by 명하준, also
//

import Foundation
import MLKitPoseDetectionAccurate

class PoseEstimator {
    private var poseDetector: PoseDetector
    
    init() {
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .singleImage
        
        self.poseDetector = PoseDetector.poseDetector(options: options)
    }
}
