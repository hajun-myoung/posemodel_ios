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
    
    func detectPose(image: VisionImage, completion: @escaping ([Pose]?) -> Void){
//    func detectPose(image: VisionImage) {
//    func detectPose(image: UIImage) {
//        var poseResults: [CGPoint] = []
        
//        guard let inputImage = MLImage(image: image) else {
//            print("Failed to Convert MLImage from UIImage")
//            // return nil
//            return
//        }
        
        guard let poseDetector = self.poseDetector else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = try? poseDetector.results(in: image)
            
            DispatchQueue.main.async {
                completion(results)
            }
        }

//        var tempPoses: [Pose]?
//        do {
//          tempPoses = try poseDetector.results(in: image)
//        } catch let error {
//          print("Failed to detect pose with error: \(error.localizedDescription).")
//          return nil
//        }
//        guard let detectedPoses = tempPoses, !detectedPoses.isEmpty else {
//          print("Pose detector returned no results.")
//          return nil
//        }
        
//        guard let poseDetector = self.poseDetector else { return }
//        poseDetector.process(inputImage) { [self] poses, error in
//        poseDetector.process(image) { [self] poses, error in
//            guard error == nil, let poses = poses, !poses.isEmpty else {
//                let errorString = error?.localizedDescription
//                print("No detected poses\n\(errorString ?? "No Error String")")
//                return
//            }
//            
//            // Pose detected. Currently, only single person detection is supported.
//            poses.forEach { pose in
//                let targets:[String:PoseLandmarkType] = [
//                    "nose": PoseLandmarkType.nose,
//                    "leftShoulder": PoseLandmarkType.leftShoulder,
//                    "rightShoulder": PoseLandmarkType.rightShoulder,
//                    "leftElbow": PoseLandmarkType.leftElbow,
//                    "rightElbow": PoseLandmarkType.rightElbow,
//                    "leftWrist": PoseLandmarkType.leftWrist,
//                    "rightWrist": PoseLandmarkType.rightWrist,
//                    "leftHip": PoseLandmarkType.leftHip,
//                    "rightHip": PoseLandmarkType.rightHip,
//                    "leftKnee": PoseLandmarkType.leftKnee,
//                    "rightKnee": PoseLandmarkType.rightKnee,
//                    "leftAnkle": PoseLandmarkType.leftAnkle,
//                    "rightAnkle": PoseLandmarkType.rightAnkle,
//                    "leftHeel": PoseLandmarkType.leftHeel,
//                    "rightHeel": PoseLandmarkType.rightHeel,
//                    "leftToe": PoseLandmarkType.leftToe,
//                    "rightToe": PoseLandmarkType.rightToe,
//                ]
//                
//                for (nodename, node) in targets {
//                    let newPoint = CGPoint(
//                        x: pose.landmark(ofType: node).position.x,
//                        y: pose.landmark(ofType: node).position.y
//                    )
//                     poseResults[nodename] = newPoint
////                    poseResults.append(newPoint)
//                }
//                self.poseResults = poseResults
//                print(poseResults)
//            }
//        }
        
        return
//        return poseResults
    }
    
//    func detectPoses(images: [VisionImage]) -> [[CGPoint]]? {
//        var poseResults: [[CGPoint]] = []
//        for image in images {
//            detectPose(image: image) { results in
//                if let poses = results {
//                    poses.forEach { pose in
//                        let targets:[String:PoseLandmarkType] = [
//                            "nose": PoseLandmarkType.nose,
//                            "leftShoulder": PoseLandmarkType.leftShoulder,
//                            "rightShoulder": PoseLandmarkType.rightShoulder,
//                            "leftElbow": PoseLandmarkType.leftElbow,
//                            "rightElbow": PoseLandmarkType.rightElbow,
//                            "leftWrist": PoseLandmarkType.leftWrist,
//                            "rightWrist": PoseLandmarkType.rightWrist,
//                            "leftHip": PoseLandmarkType.leftHip,
//                            "rightHip": PoseLandmarkType.rightHip,
//                            "leftKnee": PoseLandmarkType.leftKnee,
//                            "rightKnee": PoseLandmarkType.rightKnee,
//                            "leftAnkle": PoseLandmarkType.leftAnkle,
//                            "rightAnkle": PoseLandmarkType.rightAnkle,
//                            "leftHeel": PoseLandmarkType.leftHeel,
//                            "rightHeel": PoseLandmarkType.rightHeel,
//                            "leftToe": PoseLandmarkType.leftToe,
//                            "rightToe": PoseLandmarkType.rightToe,
//                        ]
//                        
//                        var points: [CGPoint] = []
//                        for (nodename, node) in targets {
//                            let newPoint = CGPoint(
//                                x: pose.landmark(ofType: node).position.x,
//                                y: pose.landmark(ofType: node).position.y
//                            )
//                            points.append(newPoint)
//                        }
//                        poseResults.append(points)
//                    }
//                }
//            }
//        }
//        
//        return poseResults
//    }
    
//    func get_poseresults() -> [String:CGPoint]?{
//        return self.poseResults
//    }
    
//    func get_dots() -> [CGPoint] {
//        var joints: [CGPoint] = []
//        for value in Array(self.poseResults!.values) {
//            joints.append(value)
//        }
//        
//        return joints
//    }
//    
//    func get_lines() -> [Line]{
//        let poseResults = self.poseResults!
//        
//        let lineTargets = [
//            (from: "leftShoulder", to: "rightShoulder"),
//            (from: "leftHip", to: "rightHip"),
//            (from: "leftShoulder", to: "leftElbow"),
//            (from: "leftElbow", to: "leftWrist"),
//            (from: "leftShoulder", to: "leftHip"),
//            (from: "leftHip", to: "leftKnee"),
//            (from: "leftKnee", to: "leftAnkle"),
//            (from: "leftAnkle", to: "leftHeel"),
//            (from: "leftHeel", to: "leftToe"),
//            (from: "leftToe", to: "leftAnkle"),
//            (from: "rightShoulder", to: "rightElbow"),
//            (from: "rightElbow", to: "rightWrist"),
//            (from: "rightShoulder", to: "rightHip"),
//            (from: "rightHip", to: "rightKnee"),
//            (from: "rightKnee", to: "rightAnkle"),
//            (from: "rightAnkle", to: "rightHeel"),
//            (from: "rightHeel", to: "rightToe"),
//            (from: "rightToe", to: "rightAnkle"),
//        ]
//        
//        var lines:[Line] = []
//        for (from, to) in lineTargets {
//            let newLine = Line(from: poseResults[from] ?? CGPoint(x: 0, y: 0), to: poseResults[to] ?? CGPoint(x: 100, y: 100))
//            lines.append(newLine)
//        }
//        
//        return lines
//    }
}
