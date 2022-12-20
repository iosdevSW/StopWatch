//
//  PaletteCell.swift
//  SWColorPickerView
//
//  Created by 신상우 on 2021/09/14.
//

import UIKit
import SnapKit
import Then

final class PaltteCell: UICollectionViewCell {
    //MARK: - Properties
    let paintView = UIView().then {
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
    }
    
    let checkImageView = UIImageView().then {
        $0.tintColor = .white
        $0.image = UIImage(systemName: "checkmark")
        $0.isHidden = true
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.checkImageView.image = UIImage(systemName: "checkmark")
        self.checkImageView.isHidden = true
        self.gestureRecognizers = nil
    }
    
    //MARK: - AddSubView
    private func addSubView(){
        self.addSubview(self.paintView)
        
        self.paintView.addSubview(self.checkImageView)
    }
    
    
    //MARK: - Layout
    private func layout(){
        self.paintView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(4)
            $0.trailing.bottom.equalToSuperview().offset(-4)
        }
        
        self.checkImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}

