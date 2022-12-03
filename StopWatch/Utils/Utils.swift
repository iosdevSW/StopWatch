//
//  Utils.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/31.
//

import UIKit

extension UIViewController {
    //MARK: Method
    // rootView 터치시 키보드 내림
    func hideKeyboardWhenTapped(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 기본값이 true이면 제스쳐 발동시 터치 이벤트가 뷰로 전달x
        //즉 제스쳐가 동작하면 뷰의 터치이벤트는 발생하지 않는것 false면 둘 다 작동한다는 뜻 
        view.addGestureRecognizer(tap) //view에 제스쳐추가
    }

    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    ///기본적인 확인/취소 버튼이 존재하는 알림창
    func defaultAlert(title: String?, message: String?, complete: @escaping (()->()) ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in complete() }
        [okAction,cancelAction].forEach { alert.addAction($0) }
        
        self.present(alert, animated: true)
    }
    
    ///단순 안내용 안내창 (확인 버튼만 존재)
    func notiAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}

extension UIView {
    // Timeinterval을 입력받아 시, 분, 초 튜플로 반환하는 함수.
    func divideSecond(timeInterval: TimeInterval) -> (String,String,String,String){
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
    func uiColorFromHexCode(_ hex:Int)->UIColor{
        let red = CGFloat((hex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((hex & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(hex & 0x0000FF) / 0xFF
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

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


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
