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
        
        let newAngle = calculateAngle(newVector, standard, isRadian: false)
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
            speeds.append(0)
        } else if index % rate == 0 {
            let diff = abs(point.x - lastCoordi)
            let newSpeed = diff / (dt * Double(rate))
            lastCoordi = point.x
            
            speeds.append(newSpeed)
        } else {
            speeds.append(0)
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
func dotProduct(_ vecA: CGPoint, _ vecB: CGPoint) -> Double {
    return vecA.x * vecB.x + vecA.y * vecB.y
}

extension CGPoint {
    var size: Double {
        let xSquared = pow(self.x, 2)
        let ySquared = pow(self.y, 2)
        
        return pow(xSquared + ySquared, 0.5)
    }
}

func calculateAngle(_ vecA: CGPoint, _ vecB: CGPoint, isRadian: Bool = true) -> Double {
    let converter = isRadian ? 1 : (180.0 / Double.pi)
    return acos(dotProduct(vecA, vecB) / (vecA.size * vecB.size)) * converter
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
        
        let newAngle = calculateAngle(vectorA, vectorB, isRadian: false)
        angles.append(newAngle)
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
func preprocessCoordinates(from fileURL:URL, filename: String) -> URL {
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
        fatalError("CSV Reading Failed")
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
    print(headers)
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
    
    print(leftArmAngles.count, rightArmAngles.count, leftStride.count, rightStride.count, stepLength.count, stepSpeed.count, bentAngle.count, height.count)
    /// Write as a CSV File
    var newFileURL: URL!
    
    let count = leftArmAngles.count
    var rows:[String] = []
    
    for index in 0 ..< count {
        let newRow = [
            String(leftArmAngles[index]),
            String(rightArmAngles[index]),
            String(leftStride[index]),
            String(rightStride[index]),
            String(stepLength[index]),
            String(stepSpeed[index]),
            String(bentAngle[index]),
            String(height[index])
        ]
        
        let row = newRow.joined(separator: ",")
        rows.append(row)
    }
    
    let rowString = rows.joined(separator: "\n")
    var headerString = [
        "leftArmAngles", "rightArmAngles", "leftStride", "rightStride", "stepLength", "stepSpeed", "bentAngle", "height"
    ].joined(separator: ",")
    headerString = headerString + "\n"
    
    let stringData = headerString + rowString
    
    do {
        let path = try FileManager.default.url(
            for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false
        )
        newFileURL = path.appendingPathComponent("\(filename)_intermediate_values.csv")
        try stringData.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to Create CSV")
    }
    
    return fileURL
}

/// Calculate deviation
/// - Parameter source: source array
/// - Returns: deviation of given array
func deviation(of source: [Double]) -> Double {
    var squaredData = 0.0
    let average = source.average
    
    for data in source {
        squaredData += pow((data - average), 2)
    }
    let mean = squaredData / Double(source.count)
    let deviation = pow(mean, 0.5)
    
    return deviation
}

/// Slice array to the collection of smaller sizes' array
/// - Parameters:
///   - sourceArray: This will be sliced
///   - term: How many elements in the sliced array? This one work to maximum size
/// - Returns: Return array that contain smaller size of arrays. Each small array got `1 ..< term` elements.
///
/// ### Example
/// - Source: [1, 2, 3, 4, 5, 6, 7]
/// - Term: 3
/// - Return: [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7 ] ]
func splitArray(of sourceArray: [Double], to term: Int = 40) -> [[Double]] {
    let count = sourceArray.count
    var sliceCount = count / term
    
    if sliceCount * term != count {
        sliceCount += 1
    }
    
    var slicedArray: [[Double]] = []
    for i in 0 ..< sliceCount {
        let startIndex = i * term
        let endIndex = min((i + 1) * term, count)
        
        slicedArray.append(Array(sourceArray[startIndex..<endIndex]))
    }
    
    return slicedArray
}

extension Array where Element == Double {
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}

/// Read intermediate data csv, Calculate the parameters
/// - Parameter intermediate_fileURL: intermediate data file, generated by `preprocessCoordinates()`
/// - Returns: Gait Parameters array. Left Swing Angle, Right Swing Anlge, Body Tilted, Step Assymetry, Step Length, Step Speed, GaitCycle indexes are included
func calculate_parameters(of intermediate_fileURL: URL) -> [String:Double] {
    /// Read and Validate the CSV file
    var fileDataArray: [String]!
    do {
        let fileData = try String(contentsOf: intermediate_fileURL)
        fileDataArray = fileData.components(separatedBy: "\n")
        
        // MARK: Checking the CSV contents
        // if let fileDataArray {
        //     print(fileDataArray)
        // }
    } catch {
        fatalError("CSV Reading Failed")
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
    
    /// Collect intermediate values into separately array
    var leftArmAngle: [Double] = []
    var rightArmAngle: [Double] = []
    var leftStride: [Double] = []
    var rightStride: [Double] = []
    var stepLength: [Double] = []
    var stepSpeed: [Double] = []
    var bentAngle: [Double] = []
    var height: [Double] = []
    
    for line in lines {
        leftArmAngle.append(line[0])
        rightArmAngle.append(line[1])
        leftStride.append(line[2])
        rightStride.append(line[3])
        stepLength.append(line[4])
        stepSpeed.append(line[5])
        bentAngle.append(line[6])
        height.append(line[7])
    }
    
    /// Calculate armAngle paramter
    /// left
    let splitted_leftArmAngle = splitArray(of: leftArmAngle)
    var samples_leftArmAngle: [Double] = []
    for small_leftArmAngle in splitted_leftArmAngle {
        let sorted = small_leftArmAngle.sorted { $0 > $1 }
        samples_leftArmAngle.append(sorted[3])
    }
    
    let leftSwingAngle = samples_leftArmAngle.average
    
    /// right
    let splitted_rightArmAngle = splitArray(of: rightArmAngle)
    var samples_rightArmAngle: [Double] = []
    for small_rightArmAngle in splitted_rightArmAngle {
        let sorted = small_rightArmAngle.sorted { $0 > $1 }
        samples_rightArmAngle.append(sorted[3])
    }
    
    let rightSwingAngle = samples_rightArmAngle.average

    /// Calculate StepAsymmetry
    let leftStrideDeviation = deviation(of: leftStride)
    let rightStrideDeviation = deviation(of: rightStride)
    
    let stepAsymmetry = abs(leftStrideDeviation - rightStrideDeviation) / (leftStrideDeviation + rightStrideDeviation) * 100
    
    // TODO: Read person height information, and Calculate the heightPixel Value
    let heightPixel = 0.45
    /// Calculate StepLength
    let sorted_stepLength = stepLength.sorted { $0 > $1 }
    let param_stepLength = sorted_stepLength[10] * heightPixel * 0.9
    
    /// Calculate Step Speed
    let sorted_stepSpeed = stepSpeed.sorted { $0 > $1 }
    let cmps_to_kph = 0.036 /// 1 cm per a second = 0.036 km per a hour
    let param_stepSpeed = sorted_stepSpeed[5] * heightPixel * cmps_to_kph * 0.95
    
    /// Calculate Bent Angle (Torso Bented)
    let param_bentAngle = bentAngle.average
    
    return [
        "leftSwingAngle": leftSwingAngle,
        "rightSwingAngle": rightSwingAngle,
        "stepAsymmetry": stepAsymmetry,
        "stepLength": param_stepLength,
        "stepSpeed": param_stepSpeed,
        "bodyTilt": param_bentAngle,
    ]
}
