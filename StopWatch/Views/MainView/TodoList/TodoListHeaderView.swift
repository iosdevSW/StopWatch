//
//  TodoListHeaderView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/15.
//

import UIKit
import SnapKit
import Then

final class TodoListHeaderView: UIView {
    //MARK: - Properties
    let frameStackView = UIStackView().then { //레이블 길이에 따라 동적 크기 할당
        $0.layer.cornerRadius = 6
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = .zero
        $0.backgroundColor = .white
    }

    let plusImageView = UIImageView().then {
        $0.image = UIImage(systemName: "plus.square.on.square")
        $0.tintColor = .white
    }
    
    let categoryNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .white
    }
    
    let touchViewButton = UIButton()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - addSubView
    private func addSubView(){
        self.addSubview(self.frameStackView)
        
        self.frameStackView.addSubview(self.categoryNameLabel)
        self.frameStackView.addSubview(self.plusImageView)
        self.frameStackView.addSubview(self.touchViewButton)
    }
    
    //MARK: - layout
    private func layout(){
        self.frameStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(4)
            $0.height.equalTo(30)
        }
        
        self.categoryNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }

        self.plusImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.leading.equalTo(self.categoryNameLabel.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }

        self.touchViewButton.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}
