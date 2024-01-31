//
//  ModelLoader.swift
//  posemodeltest
//
//  Created by 명하준 on 12/29/23.
//  All comments wrote by 명하준, also
//

import Foundation
import MLKitPoseDetectionAccurate
import MLKitVision

struct Line {
    let from: CGPoint
    let to: CGPoint
}

class PoseEstimator {
    private var poseDetector: PoseDetector? = nil
    private var poseResults: [String : CGPoint]? = nil
    
    init() {
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .singleImage
        
        self.poseDetector = PoseDetector.poseDetector(options: options)
        self.poseResults = [:]
        
        print("Create new Detector")
    }
    
    deinit {
        self.poseDetector = nil
        self.poseResults = nil
        print("The Pose Model Has Been De-Initialized")
    }
    
    func detectPose(image: VisionImage, completion: @escaping ([Pose]?) -> Void){
        guard let poseDetector = self.poseDetector else { return }
        var results: [Pose]? = []
        
        DispatchQueue.global(qos: .background).sync {
            do {
                results = try poseDetector.results(in: image)
            } catch let error {
                print(error)
            }
        }
        
        completion(results)
        return
    }
}
