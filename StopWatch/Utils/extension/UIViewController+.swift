//
//  UIViewController+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/13.
//

import UIKit

extension UIViewController {
    //MARK: Method
    // rootView 터치시 키보드 내림
    func hideKeyboardWhenTapped(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 기본값이 true이면 제스쳐 발동시 터치 이벤트가 뷰로 전달x
        //즉 제스쳐가 동작하면 뷰의 터치이벤트는 발생하지 않는것 false면 둘 다 작동한다는 뜻
        self.view.addGestureRecognizer(tap) //view에 제스쳐추가
    }

    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    ///기본적인 확인/취소 버튼이 존재하는 알림창
    func defaultAlert(title: String?, message: String?, complete: @escaping (()->()) ) {
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
