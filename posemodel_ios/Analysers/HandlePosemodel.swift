//
//  ModelLoader.swift
//  posemodeltest
//
//  Created by 명하준 on 12/29/23.
//  All comments wrote by 명하준, also
//

import Foundation
import TensorFlowLite
import UIKit
import os

struct Line {
    let from: CGPoint
    let to: CGPoint
}

struct Result {
    var dots: [CGPoint]
    var lines: [Line]
    // we don't need the score
    // var score: Float
}

struct Times {
    var preprocessing: Double
    var inference: Double
    var postprocessing: Double
}

typealias FileInfo = (filename: String, extension: String)
enum Model{
    static let FileInfo = (
        filename: "pose_landmark_full",
        extension: "tflite"
    )

    static let isQuantized = false
}

// ⬇️ NUY(Not Understood Yet)
// MARK: - Delegates Enum
enum Delegates: Int, CaseIterable {
  case CPU
  case Metal
  case CoreML

  var description: String {
    switch self {
    case .CPU:
      return "CPU"
    case .Metal:
      return "GPU"
    case .CoreML:
      return "NPU"
    }
  }
}
// NUY end

enum BodyPart: String, CaseIterable {
    case NOSE = "nose"
    case LEFT_EYE_INNER = "left eye inner"
    case LEFT_EYE = "left eye"
    case LEFT_EYE_OUTER = "left eye outer"
    case RIGHT_EYE_INNER = "right eye inner"
    case RIGHT_EYE = "right eye"
    case RIGHT_EYE_OUTER = "right eye outer"
    case LEFT_EAR = "left ear"
    case RIGHT_EAR = "right ear"
    case MOUTH_LEFT = "mouth left"
    case MOUTH_RIGHT = "mouth right"
    case LEFT_SHOULDER = "left shoulder"
    case RIGHT_SHOULDER = "right shoulder"
    case LEFT_ELBOW = "left elbow"
    case RIGHT_ELBOW = "right elbow"
    case LEFT_WRIST = "left wrist"
    case RIGHT_WRIST = "right wrist"
    case LEFT_PINKY = "left pinky" // The fifth finger
    case RIGHT_PINKY = "right pinky"
    case LEFT_INDEX = "left index" // The second finger
    case RIGHT_INDEX = "right index"
    case LEFT_THUMB = "left thumb"
    case RIGHT_THUMB = "right thumb"
    case LEFT_HIP = "left hip"
    case RIGHT_HIP = "right hip"
    case LEFT_KNEE = "left knee"
    case RIGHT_KNEE = "right knee"
    case LEFT_ANKLE = "left ankle"
    case RIGHT_ANKLE = "right ankle"
    case LEFT_HEEL = "lett heel"
    case RIGHT_HEEL = "right heel"
    case LEFT_TOE = "left toe"
    case RIGHT_TOE = "right toe"

    /// List of lines connecting each part.
    static let lines = [
        (from: BodyPart.LEFT_WRIST, to: BodyPart.LEFT_ELBOW),
        (from: BodyPart.LEFT_ELBOW, to: BodyPart.LEFT_SHOULDER),
        (from: BodyPart.LEFT_SHOULDER, to: BodyPart.RIGHT_SHOULDER),
        (from: BodyPart.RIGHT_SHOULDER, to: BodyPart.RIGHT_ELBOW),
        (from: BodyPart.RIGHT_ELBOW, to: BodyPart.RIGHT_WRIST),
        (from: BodyPart.LEFT_SHOULDER, to: BodyPart.LEFT_HIP),
        (from: BodyPart.LEFT_HIP, to: BodyPart.RIGHT_HIP),
        (from: BodyPart.RIGHT_HIP, to: BodyPart.RIGHT_SHOULDER),
        (from: BodyPart.LEFT_HIP, to: BodyPart.LEFT_KNEE),
        (from: BodyPart.LEFT_KNEE, to: BodyPart.LEFT_ANKLE),
        (from: BodyPart.RIGHT_HIP, to: BodyPart.RIGHT_KNEE),
        (from: BodyPart.RIGHT_KNEE, to: BodyPart.RIGHT_ANKLE),
        (from: BodyPart.LEFT_ANKLE, to: BodyPart.LEFT_HEEL),
        (from: BodyPart.RIGHT_ANKLE, to: BodyPart.RIGHT_HEEL),
        (from: BodyPart.LEFT_ANKLE, to: BodyPart.LEFT_TOE),
        (from: BodyPart.RIGHT_ANKLE, to: BodyPart.RIGHT_TOE),
        (from: BodyPart.LEFT_ANKLE, to: BodyPart.LEFT_TOE),
        (from: BodyPart.RIGHT_ANKLE, to: BodyPart.RIGHT_TOE),
    ]
}

class PoseModel {
//    print("function load_model has been loaded")
    private var interpreter: Interpreter
    
    private var inputTensor: Tensor
    private var heatsTensor: Tensor // aka outputTensor
    private var offsetsTensor: Tensor
    
    private var ratio: CGPoint = (CGPoint(x: 0, y:0))

    // The role of below initializer
    //  - Loading, Validating the TensorFlow Lite Model
    init()
    {
        do {
            let modelPath = Bundle.main.path(forResource: Model.FileInfo.filename, ofType: Model.FileInfo.extension)
            interpreter = try Interpreter(modelPath: modelPath!)
            
            try interpreter.allocateTensors()
            
            inputTensor = try interpreter.input(at: 0)
            heatsTensor = try interpreter.output(at: 0)
            offsetsTensor = try interpreter.output(at: 1)
            
            // MARK: Tensors' Dimension Information
            ///
            /// All Tensor Dimensions can be accessed by: (TensorName).shape.dimmensions
            /// Input Tensor Dimensions: [1, 256, 256, 3]
            /// Output(Heats) Tensor Dimensions: [1, 195]
            /// Offset Tensor Dimensions: [1, 1]
        } catch {
            fatalError("Failed to Load the Model File with Named \(Model.FileInfo.filename)")
        }
    }
    
    func runPoseModel(
        on pixelbuffer: CVPixelBuffer,
        from source: CGRect,
        to dest: CGSize
    ) -> (Result, Times)? {
        // Start the timers
        let preprocessingStartTime: Date
        let inferenceStartTime: Date
        let postprocessingStartTime: Date
        
        // Set the timers in mili-sec
        let preprocessingTime: TimeInterval
        let inferenceTime: TimeInterval
        let postprocessingTime: TimeInterval
        
        // Starts of the preprocessing
        preprocessingStartTime = Date()
        
        guard let data = preprocess(of: pixelbuffer, from: source)
        else {
            os_log("Preprocessing failed", type: .error)
            return nil
        }
        
        preprocessingTime = Date().timeIntervalSince(preprocessingStartTime) * 1000
        // Ends of the preprocessing
        
        // Starts of the inferencing
        inferenceStartTime = Date()
        inference(from: data)
        inferenceTime = Date().timeIntervalSince(inferenceStartTime) * 1000
        // Ends of the inferencing
        
        // Starts of the postprocessing
        postprocessingStartTime = Date()
        guard let results = postprocess(to: dest) else
        {
            print("Failed to call the postprocess function")
            return nil
        }
        postprocessingTime = Date().timeIntervalSince(postprocessingStartTime) * 1000
        // Ends of the postprocessing
        
        let times = Times(
            preprocessing: preprocessingTime,
            inference: inferenceTime,
            postprocessing: postprocessingTime
        )
        
        return (results, times)
    }
    
    private func preprocess(
        of pixelBuffer: CVPixelBuffer,
        from targetSquare: CGRect
    ) -> Data? {
        let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        
        // Check the image format is intended, the 32BGRA
        print("\n\(sourcePixelFormat)")
        assert(sourcePixelFormat == kCVPixelFormatType_32BGRA
            || sourcePixelFormat == kCVPixelFormatType_32ARGB
            || sourcePixelFormat == kCVPixelFormatType_32ABGR
            || sourcePixelFormat == kCVPixelFormatType_32RGBA
        )
        
        let modelSize = CGSize(
            width: inputTensor.shape.dimensions[2],
            height: inputTensor.shape.dimensions[1]
        )
        
        guard let thumbnail = pixelBuffer.resize(
            from: targetSquare,
            to: modelSize
        )
        else{
            return nil
        }
        
        // ⬇️ NUY(Not understood yet)
        // Below code is removing the alpha values.
        // But I am still not understanding why the 'isQuanitized' value is required, and what it is
        guard let inputData = thumbnail.rgbData(
            isModelQuantized: Model.isQuantized
        )
        // end of NUY
        else{
            os_log(
                "Failed to convert the image buffer to RGB data",
                type: .error
            )
            return nil
        }
        
        return inputData
    }
    
    private func inference(from data: Data){
        do {
            // Copy the initialized 'Data' to the input 'Tensor'
            try interpreter.copy(data, toInputAt: 0)
            
            // Run inference by invoking the 'Interpreter'
            try interpreter.invoke()
            
            heatsTensor = try interpreter.output(at: 0)
            offsetsTensor = try interpreter.output(at: 1)
        } catch {
            os_log("Failed to invoke the interpreter with error: %s", type: .error)
            return
        }
    }
    
    private func postprocess(to viewSize: CGSize) -> Result?{
        // print("\n\t**Converted Heats Tensor")
        let bytes = heatsTensor.data.toArray(type: Float32.self)
        let floatArray = bytes.map { Float32($0) }
        
        let number_of_data = 5
        let max_node = 33
        var result = Result(dots: [], lines: [])
        
        var bodyPartToDotMap = [BodyPart: CGPoint]()
        for (index, part) in BodyPart.allCases.enumerated(){
            let x_value = floatArray[index * number_of_data]
            let y_value = floatArray[index * number_of_data + 1]
            // print("x:\(x_value)\ty:\(y_value)")
            let newPosition = CGPoint(
//                x: CGFloat(x_value * Float32(ratio.x)),
                x: CGFloat(x_value),
//                y: CGFloat(y_value * Float32(ratio.y))
                y: CGFloat(y_value)
            )
            // print(newPosition)
            
            bodyPartToDotMap[part] = newPosition
            result.dots.append(newPosition)
        }
        
        do {
          try result.lines = BodyPart.lines.map { map throws -> Line in
            guard let from = bodyPartToDotMap[map.from] else {
              throw PostprocessError.missingBodyPart(of: map.from)
            }
            guard let to = bodyPartToDotMap[map.to] else {
              throw PostprocessError.missingBodyPart(of: map.to)
            }
            return Line(from: from, to: to)
          }
        } catch PostprocessError.missingBodyPart(let missingPart) {
          os_log("Postprocessing error: %s is missing.", type: .error, missingPart.rawValue)
          return nil
        } catch {
          os_log("Postprocessing error: %s", type: .error, error.localizedDescription)
          return nil
        }
        
        // print(result)
        return result
    }
    
}


// MARK: - Custom Errors
enum PostprocessError: Error {
  case missingBodyPart(of: BodyPart)
}

