//
//  MenuOptionCell.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit
import Then
import SnapKit

final class MenuOptionCell: UITableViewCell{
    //MARK: - Properties
    private let menuImageView = UIImageView()
    
    private let menuTitleLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.text = "Sample text"
    }
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .standardColor
        self.selectionStyle = .none
        
        self.addSubview(self.menuImageView)
        self.addSubview(self.menuTitleLabel)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ menu: MenuOption?) {
        self.menuImageView.image = menu?.image
        self.menuTitleLabel.text = menu?.description
    }
    
    private func layout() {
        self.menuImageView.snp.makeConstraints {
            $0.height.width.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.menuTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.menuImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
