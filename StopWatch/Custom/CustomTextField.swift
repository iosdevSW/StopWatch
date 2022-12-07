//
//  CustomTextField.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/14.
//

import UIKit

class CustomTextField: UITextField{
    var underLineWidth: CGFloat = 2
    
    let underLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubView(){
        self.addSubview(self.underLine)
    }
    
    func layout(){
        NSLayoutConstraint.activate([
            self.underLine.bottomAnchor.constraint(equalTo:self.bottomAnchor),
            self.underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.underLine.heightAnchor.constraint(equalToConstant: self.underLineWidth)
            ])
    }
    
}
