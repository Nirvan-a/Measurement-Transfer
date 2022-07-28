//
//  extension.swift
//  transition tool2
//
//  Created by nirvana on 2022/7/27.
//

import Foundation
//extension Double {
//
//    //.......
//    func perfectString() -> String {
//        let numberformatter = NumberFormatter()
//        numberformatter.maximumFractionDigits = 6
//        numberformatter.maximumIntegerDigits = 6
//
//        let string = numberformatter.string(from: self as NSNumber)!
//        return string
//    }
//}
extension Double {
    
    //保留六位小数
    func prettyPrint(places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let result = String((self * divisor).rounded() / divisor)
        return result
    }

}
