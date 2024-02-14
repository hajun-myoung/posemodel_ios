//
//  HandleData.swift
//  posemodel_ios
//
//  Created by 명하준 on 2/14/24.
//

import Foundation
import CoreFoundation

func validateFileinfo(of fileinfo: String, filename: String, fileExtension: String) -> Bool {
    let filename_length = filename.count
    let fileExtension_length = fileExtension.count
    let fileinfo_length = fileinfo.count
    
    if fileinfo_length != filename_length + fileExtension_length + 1 {
        print("The filename cannot contain any dots except for the separating name and extension")
        return false
    }

    return true
}

/// Get angles between given vector and static vector. The "given vector" is from 'from' to 'vector'
/// - Parameters:
///   - vecA: initial vector
///   - vecB: terminating vector
///   - standard: static standard vector
/// - Returns: Angles
func getStaticAngle(of vecA: [CGPoint], vector vecB: [CGPoint], standard: CGPoint = CGPoint(x: 0, y: -1)) -> [Double] {
    let vecA_count = vecA.count
    let vecB_count = vecB.count
    
    if vecA_count != vecB_count {
        fatalError("Two vector array must have same size")
    }
    
    var angles: [Double] = []
    for index in 0 ..< vecA_count {
        let newVectorX = vecB[index].x - vecA[index].x
        let newVectorY = vecB[index].y - vecA[index].y
        let newVector = CGPoint(x: newVectorX, y: newVectorY)
        
        let newAngle = dotProduct(newVector, standard, isRadian: false)
        angles.append(newAngle)
    }
    
    return angles
}

/// Calculate center points
/// - Parameters:
///   - vecA: The first vector array
///   - vecB: The second vector array
/// - Returns: Center vectors
func getCenterPoints(_ vecA: [CGPoint], _ vecB: [CGPoint]) -> [CGPoint] {
    let vecA_count = vecA.count
    let vecB_count = vecB.count
    
    if vecA_count != vecB_count {
        fatalError("Two vector array must have same size")
    }
    
    var centers: [CGPoint] = []
    for index in 0 ..< vecA_count {
        let newCenterX = (vecA[index].x + vecB[index].x) / 2
        let newCenterY = (vecA[index].y + vecB[index].y) / 2
        let newCenter = CGPoint(x: newCenterX, y: newCenterY)
        
        centers.append(newCenter)
    }
    return centers
}

/// Calculate x-coordi based speed, at a time on every `rate` frames.
///
/// - Parameters:
///   - vecA: Taget Vector array. The function will calculate this.
///   - framerate: For calculating speed, the 'time' factor is required, and it's calculated by this.
///   - rate: Calculating rate. Calculate the speed every `rate` frames.
/// - Returns: Speeds array, almost of this array will be filled up by 0. Only rate*th* frame got speed data.
func getSpeeds(of vecA: [CGPoint], on framerate: Double = 30.0, by rate: Int = 10) -> [Double] {
    let dt = 1.0 / framerate
    var lastCoordi:Double = -1
    
    var speeds: [Double] = []
    for (index, point) in vecA.enumerated() {
        if index == 0 {
            lastCoordi = point.x
        } else if index % rate == 0 {
            let diff = point.x - lastCoordi
            let newSpeed = diff / (dt * Double(rate))
            
            speeds.append(newSpeed)
        }
    }
    
    return speeds
}

/// Calculate strides from two CGPoint array. Strides ensure gte 0: If it's negative, it logs 0
/// 
/// - Parameters:
///   - vecA: Initial Vector array
///   - vecB: Terminator Vector array
///   - vecC: **Standard** Vector. Compare this with `vecA` to decide "direction"
/// - Returns: Strides array
func get_strides(of vecA: [CGPoint], vector vecB: [CGPoint], standard vecC: [CGPoint]) -> [Double] {
    let vecA_count = vecA.count
    let vecB_count = vecB.count
    
    if vecA_count != vecB_count {
        fatalError("Two vector array must have same size")
    }
    
    var differences: [Double] = []
    for index in 0 ..< vecA_count {
        var newDifference = vecB[index].x - vecA[index].x
        
        let isLeft:Bool = vecA[index].x > vecC[index].x
        if isLeft {
            newDifference *= -1
        }
        
        differences.append(newDifference >= 0 ? newDifference : 0)
    }
    
    return differences
}

/// Calculate distances by two CGPoint array
///
/// - Parameters:
///   - vecA: The first vector
///   - vecB: The second vector
/// - Returns: The distances' array
func getDistances(_ vecA: [CGPoint], _ vecB: [CGPoint]) -> [Double] {
    let vecA_count = vecA.count
    let vecB_count = vecB.count
    
    if vecA_count != vecB_count {
        fatalError("Two vector array must have same size")
    }
    
    var distances: [Double] = []
    for index in 0 ..< vecA_count {
        let xDiff = pow((vecB[index].x - vecA[index].x), 2)
        let yDiff = pow((vecB[index].y - vecA[index].y), 2)
        
        let newDistance = sqrt(xDiff + yDiff)
        distances.append(newDistance)
    }
    
    return distances
}

/// Dot Product(Inner Product)
/// - Parameters:
///   - vecA: a Vector
///   - vecB: another Vector
///   - isRadian: default true, if false, return degree
/// - Returns: Radian angle
func dotProduct(_ vecA: CGPoint, _ vecB: CGPoint, isRadian: Bool = true) -> Double {
    let radianAngle = vecA.x * vecB.x + vecA.y * vecB.y
    if isRadian {
        return radianAngle
    } else {
        return radianAngle * (180 / Double.pi)
    }
}

/// Calculate angles between three nodes. Angles of vec(nodeB to nodeA), vec(nodeB to nodeC). **Recommend to set nodeB as a common initial point**
///
/// - Parameters:
///   - nodeA: first node coordinates array
///   - nodeB: second node coordinates array
///   - nodeC: thrid node coordinates array
/// - Returns: Calculated angles array
func getAngles_fromNodesArray(_ nodeA: [CGPoint], _ nodeB: [CGPoint], _ nodeC: [CGPoint]) -> [Double] {
    let nodeA_count = nodeA.count
    let nodeB_count = nodeB.count
    let nodeC_count = nodeC.count
    
    if (nodeA_count != nodeB_count) ||
       (nodeB_count != nodeC_count) ||
       (nodeC_count != nodeA_count) {
        fatalError("nodeA, nodeB, nodeC array have to got same size")
    }
    
    var angles: [Double] = []
    for index in 0..<nodeA_count {
        let dotA = nodeA[index]
        let dotB = nodeB[index]
        let dotC = nodeC[index]
        let vectorA = CGPoint(x: dotA.x - dotB.x, y: dotA.y - dotB.y)
        let vectorB = CGPoint(x: dotC.x - dotB.x, y: dotC.y - dotB.y)
        
        let newAngle = dotProduct(vectorA, vectorB, isRadian: false)
        
    }
    
    return angles
}

/// Calculate original intermediate values from Coordinates
/// - Parameter fileURL: Coordinates CSV File URL
/// - Returns: Intermediate Values CSV File URL
///
/// ### Intermediate Values Description
/// - Arm angle (LR): Waist - Shoulder - Wrist angle
/// - Stride (LR): Waist to Heel, x-coordi difference
/// - Step length: Heel to Heel, distance
/// - Step speed: x-coordi differences between last waist avg and current waist avg
/// - Calculate one time per 10 frames
/// - Bent angle: Angle between Shoulder to Waist Vector - Vertical Vector
/// - Height: Nose to Toe average, distance
func preprocessCoordinates(from fileURL:URL) -> URL? {
    /// Read and Validate the CSV file
    var fileDataArray: [String]!
    do {
        let fileData = try String(contentsOf: fileURL)
        fileDataArray = fileData.components(separatedBy: "\n")
        
        // MARK: Checking the CSV contents
        // if let fileDataArray {
        //     print(fileDataArray)
        // }
    } catch {
        return nil
    }
    
    /// CSV to Array
    var headers: [String] = []
    var lines: [[Double]] = []
    for (idx, line) in fileDataArray.enumerated() {
        let lineComponents = line.components(separatedBy: ",")
        if idx == 0 {
            for lineComponent in lineComponents {
                headers.append(lineComponent.trimmingCharacters(in: .whitespaces))
            }
        } else {
            var numbers: [Double] = []
            for lineComponent in lineComponents {
                let trimmedData = lineComponent.trimmingCharacters(in: .whitespaces)
                let trimmedNumber = Double(trimmedData)
                
                numbers.append(trimmedNumber ?? -1.0)
            }
            
            lines.append(numbers)
        }
    }

    /// Calculating from Here
    // MARK: WARNING: The Waist Node Mark as Hip
    /// Source Nodes: Hip, Shoulder, Wrist, Heel, Nose, Toe
    let sourceNodes = [
        "leftHip", "rightHip", "leftShoulder", "rightShoulder", "leftWrist", "rightWrist", "leftHeel", "rightHeel", "nose",
    ]
    var sourceIndexes:[Int?] = []
    for node in sourceNodes {
        /// Only save X Coordinates' index
        let newIndex = headers.firstIndex(of: "\(node)_x")
        sourceIndexes.append(newIndex)
    }
    /// Validate Indexes : **nil** is not allowed
    if sourceIndexes.contains(nil) {
        let nilIndex = sourceIndexes.firstIndex(of: nil)
        fatalError("[Error] \(sourceNodes[nilIndex!]) Not Found")
    }
    
    /// Collect Source Nodes' Coordinates Separately
    var leftHipCoordinates: [CGPoint] = []
    var rightHipCoordinates: [CGPoint] = []
    var leftShoulderCoordinates: [CGPoint] = []
    var rightShoulderCoordinates: [CGPoint] = []
    var leftWristCoordinates: [CGPoint] = []
    var rightWristCoordinates: [CGPoint] = []
    var leftHeelCoordinates: [CGPoint] = []
    var rightHeelCoordinates: [CGPoint] = []
    var noseCoordinates: [CGPoint] = []
    
    for line in lines {
        let new_leftHipCoordi = CGPoint(x: line[sourceIndexes[0]!], y: line[sourceIndexes[0]! + 1])
        let new_rightHipCoordi = CGPoint(x: line[sourceIndexes[1]!], y: line[sourceIndexes[1]! + 1])
        let new_leftShoulderCoordi = CGPoint(x: line[sourceIndexes[2]!], y: line[sourceIndexes[2]! + 1])
        let new_rightShoulderCoordi = CGPoint(x: line[sourceIndexes[3]!], y: line[sourceIndexes[3]! + 1])
        let new_leftWristCoordi = CGPoint(x: line[sourceIndexes[4]!], y: line[sourceIndexes[4]! + 1])
        let new_rightWristCoordi = CGPoint(x: line[sourceIndexes[5]!], y: line[sourceIndexes[5]! + 1])
        let new_leftHeelCoordi = CGPoint(x: line[sourceIndexes[6]!], y: line[sourceIndexes[6]! + 1])
        let new_rightHeelCoordi = CGPoint(x: line[sourceIndexes[7]!], y: line[sourceIndexes[7]! + 1])
        let new_noseCoordi = CGPoint(x: line[sourceIndexes[8]!], y: line[sourceIndexes[8]! + 1])
        
        leftHipCoordinates.append(new_leftHipCoordi)
        rightHipCoordinates.append(new_rightHipCoordi)
        leftShoulderCoordinates.append(new_leftShoulderCoordi)
        rightShoulderCoordinates.append(new_rightShoulderCoordi)
        leftWristCoordinates.append(new_leftWristCoordi)
        rightWristCoordinates.append(new_rightWristCoordi)
        leftHeelCoordinates.append(new_leftHeelCoordi)
        rightHeelCoordinates.append(new_rightHeelCoordi)
        noseCoordinates.append(new_noseCoordi)
    }
    
    let leftArmAngles: [Double] = getAngles_fromNodesArray(
        leftHipCoordinates, leftShoulderCoordinates, leftWristCoordinates
    )
    let rightArmAngles: [Double] = getAngles_fromNodesArray(
        rightHipCoordinates, rightShoulderCoordinates, rightWristCoordinates
    )
    let leftStride: [Double] = get_strides(
        of: leftHipCoordinates, vector: leftHeelCoordinates, standard: noseCoordinates
    )
    let rightStride: [Double] = get_strides(
        of: rightHipCoordinates, vector: rightHeelCoordinates, standard: noseCoordinates
    )
    let stepLength: [Double] = getDistances(leftHeelCoordinates, rightHeelCoordinates)
    
    let centerOfWaistsCoordinates = getCenterPoints(leftHipCoordinates, rightHipCoordinates)
    let stepSpeed: [Double] = getSpeeds(of: centerOfWaistsCoordinates)
    
    let centerOfShoulderCoordinates = getCenterPoints(leftShoulderCoordinates, rightShoulderCoordinates)
    let bentAngle: [Double] = getStaticAngle(of: centerOfShoulderCoordinates, vector: centerOfWaistsCoordinates)
    
    let centerOfHeelCoordinates = getCenterPoints(leftHeelCoordinates, rightHeelCoordinates)
    let height: [Double] = getDistances(noseCoordinates, centerOfHeelCoordinates)
    
    return nil
}
