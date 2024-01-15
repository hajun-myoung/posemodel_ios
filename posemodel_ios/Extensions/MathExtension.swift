//
//  MathExtension.swift
//  posemodel_ios
//
//  Created by 명하준 on 1/13/24.
//

import Foundation

func rounddown(number: Double, deci: Double) -> Double {
    let factor = pow(10, deci)
    let newNumber = Double(round(factor * number) / factor)
    
    return newNumber
}
