//
//  UIView+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/13.
//

import UIKit

extension UIView {
    // Timeinterval을 입력받아 시, 분, 초 튜플로 반환하는 함수.
    func divideSecond(timeInterval: TimeInterval) -> (String,String,String,String) {
        let subSecond = Int(timeInterval / 0.01)
        let second = subSecond / 100
        let minute = second / 60
        let result = (subSecond % 100, second % 60, minute % 60,(minute / 60) % 24)
        return (returnString(result.0),returnString(result.1),returnString(result.2),returnString(result.3))
    }

    // 정수를 입력받아 두자리 수의 문자열로 포맷하여 반환
    func returnString(_ integer: Int) -> String {
        let formmater = NumberFormatter()
        formmater.minimumIntegerDigits = 2
        return formmater.string(from: NSNumber(value: integer))!
    }
    
    //색상코드를 UIColor로 바꿔주는 메소드
    func uiColorFromHexCode(_ hex:Int)->UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((hex & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(hex & 0x0000FF) / 0xFF
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
