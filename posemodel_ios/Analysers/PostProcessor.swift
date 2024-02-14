//
//  PoseProcessor.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/30/24.
//

import Foundation

class PostProcessor {
    private var lines: [Line]
    private var joints: [CGPoint]
    private var paramters: [String:Double]
    
    init(){
        self.lines = []
        self.joints = []
        self.paramters = [:]
    }
    
    
    func getLines_fromJoints(joints: [String:CGPoint]) -> [Line]{
        let poseResults = joints
        
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
            let newLine = Line(from: poseResults[from] ?? CGPoint(x: 0, y: 0), to: poseResults[to] ?? CGPoint(x: -1, y: -1))
            lines.append(newLine)
        }
        
        return lines
    }
    
    func validate_lines(lines: [Line]) -> Bool {
        var isQualified = true
        
        lines.forEach { line in
            let fromPoint = line.from
            let toPoint = line.to
            
            if fromPoint.x == -1 || fromPoint.y == -1 {
                isQualified = false
            } else if toPoint.x == -1 || toPoint.y == -1 {
                isQualified = false
            }
        }
        
        if isQualified {
            print("All Compositions of the Lines are Qualified")
        } else {
            print("Some of Lines Looks Like Undetected")
        }
        
        return isQualified
    }
}


func createCSV(for headers: [String], of dataList: [[String:CGPoint]], filename: String) -> URL {
    var fileURL: URL!
    
    let rows = dataList.map { data in
        let values = Array(data.values)
        let points = values.map { "\($0.x), \($0.y)" }
        let curRow = points.joined(separator: ", ")
        return curRow
    }
    
    let rowString = rows.joined(separator: "\n")
    let headersProcessed = headers.map { "\($0)_x, \($0)_y" }
    var headerString = headersProcessed.joined(separator: ", ")
    headerString = headerString + "\n"
    
    let stringData = headerString + rowString
    
//    print(stringData)
    
    do {
        let path = try FileManager.default.url(
            for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false
        )
        
        fileURL = path.appendingPathComponent("\(filename)_data.csv")
        try stringData.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to Create CSV")
    }
    
    return fileURL
}
