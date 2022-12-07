//
//  StopButtonTappedModalView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/15.
//

import UIKit
import SnapKit
import Then

protocol TimeSaveModalViewDelegate: AnyObject {
    func closeModalView()
    func cancelModalView()
    func exitModalView()
}

// ConcentrationViewController에서 확인 버튼 누를 때 나타나는 ModalView
final class TimeSaveModalView: UIView {
    //MARK: - Properties
    weak var delegate: TimeSaveModalViewDelegate?
    
    private let noticeLabel = UILabel().then {
        $0.text = "알   림"
        $0.font = .systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    let guideLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.text = " - 에 저장하시겠습니까?"
        $0.textAlignment = .center
        $0.textColor = .darkGray
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [acceptButton,cancelButton,notSaveButton]).then {
        
        $0.subviews.forEach {
            let btn = $0 as! UIButton
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.layer.cornerRadius = 10
            
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.titlePadding = 2
                config.background.backgroundColor = .darkGray
                btn.configuration = config
            } else {
                btn.contentEdgeInsets = UIEdgeInsets(top: 2,left: 2,bottom: 2,right: 2)
                btn.backgroundColor = .darkGray
            }
        }
        $0.distribution = .fillProportionally
        $0.spacing = 10
    }
    
    private let acceptButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
    }
    
    private let notSaveButton = UIButton().then {
        $0.setTitle("저장 안함", for: .normal)
    }
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit!!")
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.noticeLabel)
        self.addSubview(self.guideLabel)
        self.addSubview(self.buttonStackView)
    }
    
    //MARK: -  Method
    private func configure(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.acceptButton.addTarget(self, action: #selector(self.acceptButtonTapped(sender:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped(sender:)), for: .touchUpInside)
        self.notSaveButton.addTarget(self, action: #selector(self.exitButtonTapped(sender:)), for: .touchUpInside)
    }
    
    //MARK: - Layout
    private func layout(){
        self.noticeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        self.buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(self.noticeLabel.snp.bottom).offset(10)
            $0.bottom.equalTo(self.buttonStackView.snp.top).offset(-10)
        }
    }
    
    //MARK: Selector
    @objc func acceptButtonTapped(sender: UIButton){
        self.delegate?.closeModalView()
    }
    
    @objc func cancelButtonTapped(sender: UIButton){
        self.delegate?.cancelModalView()
    }
    
    @objc func exitButtonTapped(sender: UIButton){
        self.delegate?.exitModalView()
    }
}
