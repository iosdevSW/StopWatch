//
//  UITextField+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/07.
//

import UIKit

extension UITextField {
    // textField 하단에 라인 만드는 함수
    func setUnderLine(){
        let border = CALayer()
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        border.borderWidth = 1
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
