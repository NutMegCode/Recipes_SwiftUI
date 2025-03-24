//
//  Utils.swift
//  Recipes
//
//  Created by Meg on 20/3/2025.
//

import Foundation

//Convert Double? to String
func getDoubleToString(_ myNum: Double?) -> String {
    
    guard let myNum = myNum else {
        return ""
    }
    
    var strNum = ""
    
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0  // Ensure no decimal places
    
    let decimalPart = myNum.truncatingRemainder(dividingBy: 1)
    
    if decimalPart == 0 {
        formatter.maximumFractionDigits = 0  // No decimals for whole numbers
    } else if decimalPart * 10 == floor(decimalPart * 10) {
        formatter.maximumFractionDigits = 1  // Show one decimal if it only has one
    } else {
        formatter.maximumFractionDigits = 2  // Otherwise, show two decimals
    }
    strNum = formatter.string(for: myNum) ?? ""
    
    return strNum
}
