//
//  ListEditItemView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/13.
//

import UIKit
import SnapKit
import Then

final class ListEditItemView: UIView {
    private let buttonSize: CGFloat = 44
    
    lazy var button = UIButton(type: .system).then { // 수정 버튼
        $0.layer.cornerRadius = self.buttonSize / 2
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .light)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .lightGray
        $0.tintColor = .darkGray
    }
    
    let label = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.button)
        self.addSubview(self.label)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(){
        self.button.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(self.buttonSize)
        }
        
        self.label.snp.makeConstraints {
            $0.top.equalTo(self.button.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
