//
//  ContactViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/20.
//

import UIKit

final class ContactViewController: UIViewController {
    //MARK: - Properties
    private let noticeLabel = UILabel().then {
        $0.text = "버그 & 기능 개선 관련 문의를 남겨주세요.\n빠른 시일 내에 확인 후 조치하겠습니다."
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage(named: "send"), for: .normal)
        $0.backgroundColor = UIColor(red: 201/255, green: 189/255, blue: 255/255, alpha: 1)
        $0.layer.cornerRadius = 25
    }
    
    private let textView = UITextView().then {
        $0.textColor = .darkGray
        $0.contentInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = UIColor.standardColor.cgColor
        $0.layer.borderWidth = 2
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubView()
        self.layout()
        self.addTarget()
        self.hideKeyboardWhenTapped()
        self.addGesture()
        
        self.title = "문의하기"
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Gesture
    private func addGesture() {
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        upSwipeGesture.direction = .up
        
        self.textView.addGestureRecognizer(upSwipeGesture)
    }
    
    //MARK: - Selector
    @objc private func didClickSendButton() {
        print("didClickSendButton")
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.view.addSubview(self.noticeLabel)
        self.view.addSubview(self.sendButton)
        self.view.addSubview(self.textView)
    }
    
    //MARK: - layout
    private func layout() {
        self.noticeLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        self.sendButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        
        self.textView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalTo(self.sendButton.snp.top).offset(-50)
            $0.top.equalTo(self.noticeLabel.snp.bottom).offset(30)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.sendButton.addTarget(self, action: #selector(self.didClickSendButton), for: .touchUpInside)
    }
}
