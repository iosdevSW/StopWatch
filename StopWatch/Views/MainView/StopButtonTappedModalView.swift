//
//  StopButtonTappedModalView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/15.
//

import UIKit

protocol StopModalViewDelegate {
    func closeModalView()
    func cancelModalView()
    func exitModalView()
}
// ConcentrationViewController에서 확인 버튼 누를 때 나타나는 ModalView
class StopButtonTappedModalView: UIView {
    //MARK: Properties
    var delegate: StopModalViewDelegate?
    
    lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "알   림"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        self.addSubview(label)
        
        return label
    }()
    
    lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        self.addSubview(label)
        
        return label
    }()
    
    lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        return view
    }()
    
    lazy var aceptButton: UIButton = {
       let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        self.buttonStackView.addSubview(button)
        
        return button
    }()
    
    lazy var cancelButton: UIButton = {
       let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        self.buttonStackView.addSubview(button)
        
        return button
    }()
    
    lazy var exitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("저장 안함", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        self.buttonStackView.addSubview(button)
        
        
        return button
    }()
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit!!")
    }
    
    //MARK: Method
    func configure(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.aceptButton.addTarget(self, action: #selector(self.aceptButtonTapped(sender:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped(sender:)), for: .touchUpInside)
        self.exitButton.addTarget(self, action: #selector(self.exitButtonTapped(sender:)), for: .touchUpInside)
    }
    
    func layout(){
        NSLayoutConstraint.activate([
            self.noticeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.noticeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.guideLabel.topAnchor.constraint(equalTo: self.noticeLabel.bottomAnchor, constant: 10),
            self.guideLabel.bottomAnchor.constraint(equalTo: self.aceptButton.topAnchor, constant: -10),
            self.guideLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.guideLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.guideLabel.heightAnchor.constraint(equalToConstant: 80)

        ])
        
        NSLayoutConstraint.activate([
            self.buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.buttonStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
//            self.aceptButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
//            self.aceptButton.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: -36),
            self.aceptButton.leadingAnchor.constraint(equalTo: self.buttonStackView.leadingAnchor),
            self.aceptButton.widthAnchor.constraint(equalToConstant: 60),
            self.aceptButton.heightAnchor.constraint(equalToConstant: 36),
            self.aceptButton.topAnchor.constraint(equalTo: self.buttonStackView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
//            self.cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
//            self.cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: 36),
            self.cancelButton.leadingAnchor.constraint(equalTo: self.aceptButton.trailingAnchor, constant: 10),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.exitButton.leadingAnchor, constant: -10),
            self.cancelButton.widthAnchor.constraint(equalToConstant: 60),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 36),
            self.cancelButton.topAnchor.constraint(equalTo: self.buttonStackView.topAnchor),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.exitButton.trailingAnchor.constraint(equalTo: self.buttonStackView.trailingAnchor),
            self.exitButton.widthAnchor.constraint(equalToConstant: 80),
            self.exitButton.heightAnchor.constraint(equalToConstant: 36),
            self.exitButton.topAnchor.constraint(equalTo: self.buttonStackView.topAnchor),
            self.exitButton.bottomAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor)
        ])
    }
    
    //MARK: Selector
    @objc func aceptButtonTapped(sender: UIButton){
        self.delegate?.closeModalView()
    }
    
    @objc func cancelButtonTapped(sender: UIButton){
        self.delegate?.cancelModalView()
    }
    
    @objc func exitButtonTapped(sender: UIButton){
        self.delegate?.exitModalView()
    }
}
