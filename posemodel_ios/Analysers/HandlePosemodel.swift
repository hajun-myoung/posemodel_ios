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
    }
    
    func detectPose(image: VisionImage){
        guard let poseDetector = self.poseDetector else { return }
        poseDetector.process(image) { [self] poses, error in
            guard error == nil, let poses = poses, !poses.isEmpty else {
                let errorString = error?.localizedDescription
                print("No detected poses\n\(errorString ?? "No Error String")")
                return
            }
            
            var poseResults:[String:CGPoint] = [:]
            // Pose detected. Currently, only single person detection is supported.
            poses.forEach { pose in
                let targets:[String:PoseLandmarkType] = [
                    "nose": PoseLandmarkType.nose,
                    "leftShoulder": PoseLandmarkType.leftShoulder,
                    "rightShoulder": PoseLandmarkType.rightShoulder,
                    "leftElbow": PoseLandmarkType.leftElbow,
                    "rightElbow": PoseLandmarkType.rightElbow,
                    "leftWrist": PoseLandmarkType.leftWrist,
                    "rightWrist": PoseLandmarkType.rightWrist,
                    "leftHip": PoseLandmarkType.leftHip,
                    "rightHip": PoseLandmarkType.rightHip,
                    "leftKnee": PoseLandmarkType.leftKnee,
                    "rightKnee": PoseLandmarkType.rightKnee,
                    "leftAnkle": PoseLandmarkType.leftAnkle,
                    "rightAnkle": PoseLandmarkType.rightAnkle,
                    "leftHeel": PoseLandmarkType.leftHeel,
                    "rightHeel": PoseLandmarkType.rightHeel,
                    "leftToe": PoseLandmarkType.leftToe,
                    "rightToe": PoseLandmarkType.rightToe,
                ]
                
                for (nodename, node) in targets {
                    let newPoint = CGPoint(
                        x: pose.landmark(ofType: node).position.x,
                        y: pose.landmark(ofType: node).position.y
                    )
                    poseResults[nodename] = newPoint
                }
            }
            self.poseResults = poseResults
        }
    }
    
    func get_poseresults() -> [String:CGPoint]?{
        return self.poseResults
    }
    
    func get_dots() -> [CGPoint] {
        var joints: [CGPoint] = []
        for value in Array(self.poseResults!.values) {
            joints.append(value)
        }
        
        return joints
    }
    
    func get_lines() -> [Line]{
        let poseResults = self.poseResults!
        
        let lineTargets = [
            (from: "leftShoulder", to: "rightShoulder"),
            (from: "leftHip", to: "rightHip"),
            (from: "leftShoulder", to: "leftElbow"),
            (from: "leftElbow", to: "leftWrist"),
            (from: "leftShoulder", to: "leftHip"),
            (from: "leftHip", to: "leftKnee"),
            (from: "leftKnee", to: "leftAnkle"),
            (from: "leftAnkle", to: "leftHeel"),
            (from: "leftHeel", to: "leftToe"),
            (from: "leftToe", to: "leftAnkle"),
            (from: "rightShoulder", to: "rightElbow"),
            (from: "rightElbow", to: "rightWrist"),
            (from: "rightShoulder", to: "rightHip"),
            (from: "rightHip", to: "rightKnee"),
            (from: "rightKnee", to: "rightAnkle"),
            (from: "rightAnkle", to: "rightHeel"),
            (from: "rightHeel", to: "rightToe"),
            (from: "rightToe", to: "rightAnkle"),
        ]
        
        var lines:[Line] = []
        for (from, to) in lineTargets {
            let newLine = Line(from: poseResults[from]!, to: poseResults[to]!)
            lines.append(newLine)
        }
        
        return lines
    }
}
