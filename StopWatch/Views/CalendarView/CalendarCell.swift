//
//  CalendarCell.swift
//  SWCalendar
//
//  Created by 신상우 on 2021/08/30.
//

import UIKit
import Then
import SnapKit

final class CalendarCell: UICollectionViewCell {
    //MARK: - Properties
    private let frameView = UIView().then {
        $0.layer.cornerRadius = 16
    }
    
    let dataCheckView = UIImageView().then {
        $0.tintColor = .darkGray
        $0.image = UIImage(systemName: "checkmark")
    }
    
    let dateLabel = UILabel().then {
        $0.font = UIFont(name: "Chalkboard SE", size: 16)
    }
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        
        self.layer.cornerRadius = 10
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    func configureHeaderCell(_ row: Int) {
        self.isUserInteractionEnabled = false
        self.dateLabel.textColor = .darkGray
        self.dataCheckView.isHidden = true
        
        if row == 0 { self.dateLabel.textColor = .red }
        if row == 6 { self.dateLabel.textColor = .blue }
    }
    
    func configureCell() {
        self.dateLabel.textColor = .darkGray
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.dataCheckView.isHidden = true
    }
    
    //MARK: - addSubView
    private func addSubView(){
        self.addSubview(self.frameView)
        
        self.frameView.addSubview(self.dataCheckView)
        self.frameView.addSubview(self.dateLabel)
    }
    
    private func layout(){
        self.frameView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.dateLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }

        self.dataCheckView.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.dateLabel.snp.top)
        
        }
    }
}
