//
//  EditColorView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/01/08.
//

import UIKit
import RealmSwift

enum ColorViewMode {
    case edit
    case add
}

final class EditColorView: UIView {
    //MARK: - Properties
    var palette: Palettes?
    let colorViewMode: ColorViewMode
    let realm = try! Realm()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.text = "색상 추가"
        $0.font = UIFont(name: "GodoM", size: 18)
    }
    
    private let guideLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .light)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.text = "색상코드를 입력해주세요."
    }
    
    private let getColorCodeTextfield = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.autocapitalizationType = .allCharacters // 대문자만 입력
        let attributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14) ]
        $0.attributedPlaceholder = NSAttributedString(string: "ex)ABCDEF",
                                                      attributes: attributes )
    }
    
    private let colorPreView = UIView().then {
        $0.layer.cornerRadius = 4
    }
    
    private let addButton = UIButton().then {
        $0.setTitle("add", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .light)
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 6
        $0.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .red
    }
    
    private let deleteColrButton = UIButton().then {
        $0.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        $0.tintColor = .darkGray
        $0.isHidden = true
    }
    
    init(_ mode: ColorViewMode, _ palette: Palettes?) {
        self.colorViewMode = mode
        self.palette = palette
        super.init(frame: .zero)
        self.addsubView()
        self.layout()
        self.addTarget()
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("addViewDeinit")
    }
    
    //MARK: - Method
    /// 16진수인지 검사하는 메소드
    private func isHexCode(_ ascii: UInt8) -> Bool {
        if ascii >= 65 && ascii <= 70 { return true } // A - F 만 통과
        if ascii >= 48 && ascii <= 57 { return true } // 숫자만 통과
        
        return false
    }
    
    ///글자 수 제한 메소드
    private func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }else {
            guard let isASCII = textField.text?.last?.isASCII else { return }
            // 아스키코드 아니면 지우기!
            if isASCII == false {
                textField.deleteBackward()
            }
            guard let ascii = textField.text?.last?.asciiValue else { return }
            
            guard self.isHexCode(ascii) else { // 16진수가 아니면 지우기
                textField.deleteBackward()
                return
            }
        }
    }
    
    private func configure() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        
        switch self.colorViewMode {
        case .edit:
            guard let colorCode = self.palette?.colorCode else {return }
            self.getColorCodeTextfield.text = String(colorCode, radix: 16).uppercased()
            self.colorPreView.backgroundColor = self.uiColorFromHexCode(colorCode)
            
            self.addButton.setTitle("edit", for: .normal)
            self.titleLabel.text = "색상 편집"
            self.deleteColrButton.isHidden = false
        case .add:
            self.addButton.setTitle("add", for: .normal)
            self.titleLabel.text = "색상 추가"
        }
    }
    
    //MARK: - Selector
    // textfield값이 변할때마다 불리는 액션 함수
    @objc func didEditingChanged(_ tf: UITextField) {
        //글자 수 제한
        self.checkMaxLength(textField: tf, maxLength: 6)
        
        //색 미리보기
        if let hexCode = Int(tf.text ?? "", radix: 16) {
            self.colorPreView.backgroundColor = self.uiColorFromHexCode(hexCode)
        }
    }
    
    @objc func didClickAddColorButton(_ sender: UIButton) {
        guard let hexCode = Int(self.getColorCodeTextfield.text ?? "", radix: 16) else { return }
        try! realm.write{
            let newColorCode = Palettes()
            newColorCode.colorCode = hexCode
            realm.add(newColorCode)
        }
        NotificationCenter.default.post(name: .closeColorEditView, object: nil)
    }
    
    @objc func didClickDeleteColorButton(_ sender: UIButton){
        try! realm.write{
            realm.delete(self.palette!)
        }
        NotificationCenter.default.post(name: .closeColorEditView, object: nil)
    }
    
    @objc func didClickEditColorButton(_ sender: UIButton) {
        guard let hexCode = Int(self.getColorCodeTextfield.text ?? "", radix: 16) else { return }
        try! realm.write{
            guard let palette else { return }
            palette.colorCode = hexCode
        }
        NotificationCenter.default.post(name: .closeColorEditView, object: nil)
    }
    
    @objc func didClickCloseEditColorViewButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: .closeColorEditView, object: nil)
    }
    
    //MARK: - AddSubView
    private func addsubView(){
        self.addSubview(self.titleLabel)
        self.addSubview(self.guideLabel)
        self.addSubview(self.getColorCodeTextfield)
        self.addSubview(self.colorPreView)
        self.addSubview(self.addButton)
        self.addSubview(self.cancelButton)
        self.addSubview(self.deleteColrButton)
    }
    
    //MARK: - Layout
    private func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.getColorCodeTextfield.snp.makeConstraints {
            $0.top.equalTo(self.guideLabel.snp.bottom).offset(20)
            $0.leading.equalTo(self.guideLabel.snp.leading)
            $0.width.equalTo(100)
        }
        
        self.addButton.snp.makeConstraints {
            $0.leading.equalTo(self.getColorCodeTextfield.snp.trailing).offset(10)
            $0.top.bottom.equalTo(self.getColorCodeTextfield)
            $0.width.equalTo(40)
        }
        
        self.colorPreView.snp.makeConstraints {
            $0.top.equalTo(self.getColorCodeTextfield.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().offset(-14)
            $0.leading.equalTo(self.getColorCodeTextfield.snp.leading)
            $0.trailing.equalTo(self.addButton.snp.trailing)
        }
        
        self.cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.width.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        self.deleteColrButton.snp.makeConstraints {
            $0.leading.equalTo(self.colorPreView.snp.trailing).offset(10)
            $0.centerY.equalTo(self.colorPreView.snp.centerY).offset(-1)
            $0.width.height.equalTo(24)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget(){
        //글자 수를 제한하기 textfield에 액션 추가.
        self.getColorCodeTextfield.addTarget(self, action: #selector(self.didEditingChanged(_:)), for: .editingChanged)
        self.deleteColrButton.addTarget(self, action: #selector(self.didClickDeleteColorButton(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.didClickCloseEditColorViewButton(_:)), for: .touchUpInside)
        
        let addButtonSelector = self.colorViewMode == .add ? #selector(self.didClickAddColorButton(_:)) : #selector(self.didClickEditColorButton(_:))
        self.addButton.addTarget(self, action: addButtonSelector, for: .touchUpInside)
    }
}
 
 
    

