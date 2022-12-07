//
//  UIColor+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/07.
//

import UIKit

extension UIColor {
    class var customBrownColor:UIColor {
        get {
            return UIColor(red: 130/255, green: 84/255, blue: 52/255, alpha: 1.0)
        }
    }
    
    class var standardColor:UIColor {
        get{
            return UIColor(red: 242/255, green: 239/255, blue: 255/255, alpha: 1.0)
        }
    }
    
    class var customPurpleColor:UIColor {
        return UIColor(red: 226/255, green: 219/255, blue: 255/255, alpha: 1.0)
    }
    
    // 배경색 어두운 정도의 따라 글자 컬러
    var isDarkColor: Bool {
        var r,g,b,a:CGFloat
        (r,g,b,a) = (0,0,0,0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        return lum > 0.96
    }
}
