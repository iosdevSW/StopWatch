//
//  RoundTextField.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/30.
//

import UIKit

final class RoundTextField: UIView {
    private let textfield = UITextField()
    
    var placeHolder: String = "" {
        didSet {
            self.textfield.placeholder = placeHolder
        }
    }
    
    var isSecureTextEntry: Bool = false {
        didSet {
            self.textfield.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var text: String? {
        return self.textfield.text
        
    }
    
    var delegate: UITextFieldDelegate? {
        didSet {
            self.textfield.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.tertiarySystemGroupedBackground.cgColor
        
        self.addSubview(self.textfield)
        
        self.textfield.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
