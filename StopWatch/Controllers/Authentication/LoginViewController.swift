//
//  AuthViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/30.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "공부습관"
        $0.textColor = UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1)
        $0.font = UIFont.italicSystemFont(ofSize: 40)
    }
    
    private let loginLabel = UILabel().then {
        $0.text = "login"
        $0.textColor = .customPurpleColor
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    private let emailTextField = RoundTextField().then {
        $0.placeHolder = "abc@email.com"
    }
    
    private let passWordTextField = RoundTextField().then {
        $0.placeHolder = "PW"
        $0.isSecureTextEntry = true
    }
    
    private let loginButton = UIButton(type: .system).then {
        $0.backgroundColor = .standardColor
        $0.setTitle("LOGIN", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private let warningLabel = UILabel().then {
        $0.textColor = .red
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let registerationButton = UIButton(type: .system).then {
        $0.backgroundColor = .white
        let title = "아직 아이디가 없다면? 회원가입"
        let attributedTitle = NSMutableAttributedString(string: title,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                                     .foregroundColor: #colorLiteral(red: 0.7810429931, green: 0.7810428739, blue: 0.7810428739, alpha: 1),
                                                                     NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
                                                                     .underlineColor: #colorLiteral(red: 0.7810429931, green: 0.7810428739, blue: 0.7810428739, alpha: 1)])
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1), range: (title as NSString).range(of: "회원가입"))
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private let resetPasswordButton = UIButton(type: .system).then {
        $0.backgroundColor = .white
        let title = "P/W 찾기"
        let attributedTitle = NSMutableAttributedString(string: title,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                                     .foregroundColor: #colorLiteral(red: 0.7810429931, green: 0.7810428739, blue: 0.7810428739, alpha: 1),
                                                                     NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
                                                                     .underlineColor: #colorLiteral(red: 0.7810429931, green: 0.7810428739, blue: 0.7810428739, alpha: 1)])
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1), range: (title as NSString).range(of: "P/W 찾기"))
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        self.hideKeyboardWhenTapped()
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.emailTextField.delegate = self
        self.passWordTextField.delegate = self
    }
    
    //MARK: Seletor
    @objc private func didClickLoginButton() {
        guard let email = self.emailTextField.text,
              let password = self.passWordTextField.text else {
            notiAlert(title: "이메일과 패스워드를 입력해주세요.", message: nil)
            return
        }
        
        let userInfo = User(email: email, password: password)
        
        Auth.auth().signIn(withEmail: userInfo.email, password: userInfo.password) { (result,error) in
            guard let result else { self.errorHandler((error! as NSError)); return }
            if result.user.isEmailVerified {
                NotificationCenter.default.post(name: .changeAuthState, object: nil)
                self.dismiss(animated: true)
            } else {
                let alert = UIAlertController(title: nil, message: "이메일 인증이 필요합니다.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let okAction = UIAlertAction(title: "인증메일 재전송", style: .default) { _ in
                    result.user.sendEmailVerification() { error in
                        if error == nil {
                            self.notiAlert(title: "전송완료", message: "인증 후 다시 시도해주세요.")
                        }
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func didClickRegistButton() {
        self.navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @objc private func didClickResetPWButton() {
        let tempEmail = self.emailTextField.text ?? ""
        
        let alert = UIAlertController(title: "비밀번호 재설정", message: "비밀번호를 재설정하실 이메일을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "abc@naver.com"
            tf.text = tempEmail
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let send = UIAlertAction(title: "재설정 메일 전송", style: .default) { _ in
            let email = alert.textFields?[0].text ?? ""
            let user = User(email: email, password: "")
            Auth.auth().sendPasswordReset(withEmail: user.email) { error in
                if let error {
                    self.errorHandler(error as NSError)
                } else {
                    self.notiAlert(title: "이메일 전송 성공", message: "전송된 이메일을 확인하고 비밀번호 재설정 후 로그인을 시도해주세요.")
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(send)
        
        self.present(alert, animated: true)
    }
    
    private func errorHandler(_ error: NSError) {
        switch error.code {
        case 17011:
            let alert = UIAlertController(title: nil, message: "회원정보가 없습니다.\n회원가입 하시겠습니까?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let okAction = UIAlertAction(title: "회원가입", style: .default) { _ in
                self.navigationController?.pushViewController(RegisterViewController(), animated: true)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
        case 17008:
            self.notiAlert(title: "알 림", message: "올바르지 않은 이메일 형식입니다.")
        default: self.notiAlert(title: "잘못된 계정정보입니다.", message: nil)
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
        self.view.addSubview(loginLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passWordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(warningLabel)
        self.view.addSubview(registerationButton)
        self.view.addSubview(resetPasswordButton)
    }
}

extension LoginViewController{
    //MARK: NSLayOut
    private func layout(){
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
            $0.centerX.equalToSuperview()
        }
        
        self.loginLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(15)
        }
        
        self.emailTextField.snp.makeConstraints {
            $0.top.equalTo(self.loginLabel.snp.bottom).offset(30)
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
        
        self.loginButton.snp.makeConstraints {
            $0.top.equalTo(self.passWordTextField.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(50)
        }
        
        self.warningLabel.snp.makeConstraints {
            $0.leading.equalTo(self.passWordTextField)
            $0.top.equalTo(self.passWordTextField.snp.bottom).offset(4)
        }
        
        self.registerationButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(4)
            $0.leading.equalTo(self.loginButton.snp.leading)
        }
        
        self.resetPasswordButton.snp.makeConstraints {
            $0.top.equalTo(self.registerationButton)
            $0.leading.equalTo(self.registerationButton.snp.trailing).offset(20)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.loginButton.addTarget(self, action: #selector(self.didClickLoginButton), for:.touchUpInside)
        self.registerationButton.addTarget(self, action: #selector(self.didClickRegistButton), for: .touchUpInside)
        self.resetPasswordButton.addTarget(self, action: #selector(self.didClickResetPWButton), for: .touchUpInside)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.warningLabel.text = ""
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = .standardColor
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
        
        self.loginButton.isEnabled = true
        self.loginButton.backgroundColor = UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1)
        
        return
    }
}
