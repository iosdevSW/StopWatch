//
//  RegisterViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/31.
//

import UIKit
import FirebaseAuth

final class RegisterViewController: UIViewController {
    private let titleLabel = UILabel().then {
        $0.text = "Email로 회원가입"
        $0.textColor = UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    private let emailTextField = RoundTextField().then {
        $0.placeHolder = "abc@email.com"
    }
    
    private let passWordTextField = RoundTextField().then {
        $0.placeHolder = "PW"
        $0.isSecureTextEntry = true
    }
    
    private let registButton = UIButton(type: .system).then {
        $0.backgroundColor = .standardColor
        $0.setTitle("인증 이메일 전송", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private let warningLabel = UILabel().then {
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 14)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "회원가입"
        
        self.hideKeyboardWhenTapped()
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.emailTextField.delegate = self
        self.passWordTextField.delegate = self
    }
    
    //MARK: Seletor
    @objc private func didClickRegistButton() {
        guard let email = self.emailTextField.text,
              let password = self.passWordTextField.text else {
            notiAlert(title: "이메일과 패스워드를 입력해주세요.", message: nil)
            return
        }
        
        let userInfo = User(email: email, password: password)
        Auth.auth().createUser(withEmail: userInfo.email, password: userInfo.password) { (result,error) in
            guard let result else { self.errorHandler((error! as NSError)); return }
            result.user.sendEmailVerification { error in
                guard error == nil else { self.notiAlert(title: "인증 메일 전송 실패", message: nil); return }
                self.notiAlert(title: "인증 메일이 전송되었습니다.", message: "인증 후 로그인을 시도해주세요.") { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func errorHandler(_ error: NSError) {
        switch error.code {
        case 17007: self.notiAlert(title: "이미 존재하는 계정입니다.", message: nil)
        default: self.notiAlert(title: "잘못된 형식입니다..", message: nil)
        }
    }
    
    /*
     @objc func keyboardWillShow(notification:NSNotification){
     print("keyboardWillShow")
     if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
     if self.view.frame.origin.y == 0{
     self.view.frame.origin.y -= keyboardSize.height
     }
     }
     }
     @objc func keyboardWillHide(notification:NSNotification){
     print("keyboardWillHide")
     if self.view.frame.origin.y != 0{
     self.view.frame.origin.y = 0
     }
     }
     
     func moveViewWithKeyboard(){
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     */
    
    //MARK: - AddSubView
    func addSubView(){
        self.view.addSubview(titleLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passWordTextField)
        self.view.addSubview(registButton)
        self.view.addSubview(warningLabel)
    }
}

extension RegisterViewController{
    //MARK: NSLayOut
    private func layout(){
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalToSuperview()
        }
    
        self.emailTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(30)
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        self.passWordTextField.snp.makeConstraints {
            $0.top.equalTo(self.emailTextField.snp.bottom).offset(10)
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        self.registButton.snp.makeConstraints {
            $0.top.equalTo(self.passWordTextField.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(50)
        }
        
        self.warningLabel.snp.makeConstraints {
            $0.leading.equalTo(self.passWordTextField)
            $0.top.equalTo(self.passWordTextField.snp.bottom).offset(4)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.registButton.addTarget(self, action: #selector(self.didClickRegistButton), for:.touchUpInside)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.warningLabel.text = ""
        self.registButton.isEnabled = false
        self.registButton.backgroundColor = .standardColor
        guard let email = self.emailTextField.text,
              let password = self.passWordTextField.text else { return }
        
        let userInfo = User(email: email, password: password)
        
        if !userInfo.isValidEmail() {
            self.warningLabel.text = "잘못된 이메일 형식입니다."
            return
        }
        
        if !userInfo.isValidPassword() {
            self.warningLabel.text = "비밀번호는 8글자 이상 영문,숫자를 포함해야합니다."
            return
        }
        
        self.registButton.isEnabled = true
        self.registButton.backgroundColor = UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1)
        
        return
    }
}
