//
//  CategoryCell.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/26.
//

import UIKit
import Then
import SnapKit

final class CategoryCell: UITableViewCell {
    //MARK: - Properties
    let cellView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = .zero
    }
    
    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .light)
        $0.textColor = .black
    }
    
    let valueLabel = TimeLabel(.hmss).then {
        $0.font = .systemFont(ofSize: 18, weight: .light)
        $0.textColor = .darkGray
    }
    
    let colorView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    private func configure(){
        self.backgroundColor = .white
        self.selectionStyle = .none
    }
    
    func configureCell(_ segment: SegmentData) {
        self.valueLabel.updateTime(self.divideSecond(timeInterval: segment.value ))
        
        guard let segment = segment.segment else { return }
        self.colorView.backgroundColor = self.uiColorFromHexCode(segment.colorCode)
        self.nameLabel.text = segment.name
    }
    
    func configureCell(_ segment: Segments) {
        self.nameLabel.text = segment.name
        self.colorView.backgroundColor = self.uiColorFromHexCode(segment.colorCode)
    }
    
    //MARK: - AddsubView
    private func addSubView(){
        self.addSubview(self.cellView)
        
        self.cellView.addSubview(self.nameLabel)
        self.cellView.addSubview(self.valueLabel)
        self.cellView.addSubview(self.colorView)
    }
    
    //MARK: - Layout
    private func layout() {
        self.cellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.bottom.equalToSuperview().offset(-2)
        }
        
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.cellView.snp.top).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.valueLabel.snp.makeConstraints {
            $0.top.equalTo(self.nameLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-2)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.colorView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(self.frame.height)
            $0.height.equalTo(self.frame.height)
        }
    }
}
