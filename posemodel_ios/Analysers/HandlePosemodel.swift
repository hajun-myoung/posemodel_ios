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
//        var detectionError: Error?
        
        DispatchQueue.global(qos: .background).sync {
            do {
                results = try poseDetector.results(in: image)
            } catch let error {
                print(error)
//                detectionError = error
            }
        }
        
        completion(results)
        
//        DispatchQueue.main.async { () in
//            completion(results)
//        }
        
//        DispatchQueue.global(qos: .background).async {
//            var results: [Pose]? = []
//            var detectionError: Error?
//            do {
//                results = try poseDetector.results(in: image)
//            } catch let error {
//                print(error)
//                detectionError = error
//            }
//            
//            DispatchQueue.main.async { [self] in
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
//                        for (nodename, node) in targets {
//                            let newPoint = CGPoint(
//                                x: pose.landmark(ofType: node).position.x,
//                                y: pose.landmark(ofType: node).position.y
//                            )
//                            poseResults![nodename] = newPoint
//                        }
//
//                        completion(poseResults)
//                    }
//                }
//            }
//        }

        return
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
}
