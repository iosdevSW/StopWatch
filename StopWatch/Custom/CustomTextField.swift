//
//  CustomTextField.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/14.
//

import UIKit

final class CustomTextField: UITextField{
    private var underLineWidth: CGFloat = 2
    
    let underLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - AddSubView
    private func addSubView(){
        self.addSubview(self.underLine)
    }
    
    //MARK: - Layout
    private func layout(){
        self.underLine.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.underLineWidth)
        }
    }
}
