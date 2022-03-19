//
//  EditColorView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/01/08.
//

import UIKit
import RealmSwift

class EditColorView: UIView {
    var hexCode = 0
    var palettes: Palettes?
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.text = "색상 추가"
        label.font = UIFont(name: "GodoM", size: 18)
        
        return label
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.text = "색상코드를 입력해주세요."
        
        return label
    }()
    
    let getColorCodeTextfield:UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .allCharacters // 대문자만 입력
        let attributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14) ]
        tf.attributedPlaceholder = NSAttributedString(
            string: "ex)ABCDEF", attributes: attributes )
        
        return tf
    }()
    
    let colorPreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .light)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        button.layer.borderColor = UIColor.darkGray.cgColor
    
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .red
        
        return button
    }()
    
    let deleteColrButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.tintColor = .darkGray
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addsubView()
        self.layout()
        self.addTarget()
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.deleteColrButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("addViewDeinit")
    }
    
    func addsubView(){
        self.addSubview(self.titleLabel)
        self.addSubview(self.guideLabel)
        self.addSubview(self.getColorCodeTextfield)
        self.addSubview(self.colorPreView)
        self.addSubview(self.addButton)
        self.addSubview(self.cancelButton)
        self.addSubview(self.deleteColrButton)
    }
    
    func addTarget(){
        //글자 수를 제한하기 textfield에 액션 추가.
        self.getColorCodeTextfield.addTarget(self, action: #selector(self.didEditingChanged(_:)), for: .editingChanged)
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.guideLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),
            self.guideLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.getColorCodeTextfield.topAnchor.constraint(equalTo: self.guideLabel.bottomAnchor, constant: 20),
            self.getColorCodeTextfield.leadingAnchor.constraint(equalTo: self.guideLabel.leadingAnchor),
            self.getColorCodeTextfield.widthAnchor.constraint(equalToConstant: 100),
            
            self.addButton.leadingAnchor.constraint(equalTo: self.getColorCodeTextfield.trailingAnchor, constant: 10),
            self.addButton.topAnchor.constraint(equalTo: self.getColorCodeTextfield.topAnchor),
            self.addButton.bottomAnchor.constraint(equalTo: self.getColorCodeTextfield.bottomAnchor),
            self.addButton.widthAnchor.constraint(equalToConstant: 40),
            
            self.colorPreView.topAnchor.constraint(equalTo: self.getColorCodeTextfield.bottomAnchor, constant: 14),
            self.colorPreView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            self.colorPreView.leadingAnchor.constraint(equalTo: getColorCodeTextfield.leadingAnchor),
            self.colorPreView.trailingAnchor.constraint(equalTo: self.addButton.trailingAnchor),
            
            self.cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            self.cancelButton.widthAnchor.constraint(equalToConstant: 20),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 20),
            ])
        
        NSLayoutConstraint.activate([
            self.deleteColrButton.leadingAnchor.constraint(equalTo: self.colorPreView.trailingAnchor, constant: 10),
            self.deleteColrButton.centerYAnchor.constraint(equalTo: self.colorPreView.centerYAnchor, constant: -1),
            self.deleteColrButton.widthAnchor.constraint(equalToConstant: 24),
            self.deleteColrButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    //16진수인지 검사하는 메소드
    func isChar(ascii: UInt8) -> Bool {
        if ascii >= 65 && ascii <= 70 { return true } // A - F 만 통과
        if ascii >= 48 && ascii <= 57 { return true } // 숫자만 통과
        
        return false
    }
    
    //글자 수 제한 메소드
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }else {
            guard let isASCII = textField.text?.last?.isASCII else { return }
            // 아스키코드 아니면 지우기!
            if isASCII == false {
                textField.deleteBackward()
            }
            guard let ascii = textField.text?.last?.asciiValue else { return }
            
            guard self.isChar(ascii: ascii) else { // 16진수가 아니면 지우기
                textField.deleteBackward()
                return
            }
        }
        
    }
    
    // textfield값이 변할때마다 불리는 액션 함수
    @objc func didEditingChanged(_ tf: UITextField) {
        //글자 수 제한
        self.checkMaxLength(textField: self.getColorCodeTextfield, maxLength: 6)
        
        //색 미리보기
        if let hexCode = Int(tf.text ?? "", radix: 16) {
            self.addButton.tag = hexCode
            let preViewColor = self.uiColorFromHexCode(hexCode)
            self.colorPreView.backgroundColor = preViewColor
        }
    }
}
 
 
    

