//
//  GoalTimeView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/19.
//

import UIKit
import SnapKit

final class GoalTimeView: UIView {
    //MARK: - Properties
    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "flag.fill")
        $0.tintColor = .darkGray
    }
    
    let timeLabel = TimeLabel(.hm).then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.backgroundColor = .white
        $0.textAlignment = .center
        $0.textColor = .darkGray
    }
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.actionButton)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout
    private func layout() {
        self.addSubview(self.imageView)
        self.addSubview(self.timeLabel)
        
        self.imageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
}
