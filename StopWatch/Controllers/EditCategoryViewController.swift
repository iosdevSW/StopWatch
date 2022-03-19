//
//  EditCategoryViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/14.
//
import UIKit
import RealmSwift

class EditCategoryViewController: UIViewController {
    let palette = Palette()
    var selectedColorCode: Int?
    var selectedColorRow: Int?
    var selectedSegmentRow: Int?
    var saveDate:String = ""
    let realm = try! Realm()
    var editColorView: EditColorView?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        label.text = "Name"
        
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        label.text = "Palette"

        return label
    }()
    
    lazy var getNameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 18, weight: .light)
        tf.textColor = .black
        tf.underLine.backgroundColor = .black
        
        return tf
    }()
    
    let paletteView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(PaltteCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .white
        
        return view
    }()
    
    let okButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        button.tag = 1
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        button.tag = 2
    
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let border = CALayer()
        self.getNameTextField.layer.addSublayer(border)
        self.addSubView()
        self.layout()
        self.addTarget()
        self.paletteView.delegate = self
        self.paletteView.dataSource = self
        self.navigationItem.hidesBackButton = true
        self.hideKeyboardWhenTapped()
        self.navigationItem.title = "category"
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
    }
    
    func openAlert(){
        let alert = UIAlertController(title: "경 고", message: "색과 이름을 모두 입력해주세요.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func date() -> String{
        let date = DateFormatter()
        date.locale = Locale(identifier: Locale.current.identifier)
        date.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        date.dateFormat = "YYYY. MM. dd"
        
        return date.string(from: Date())
    }
    
    func addCategoryMtd(){
        guard let row = self.selectedColorCode else { // 색을 정했는지 검사 안했으면 경고창 띄우기
            self.openAlert()
            return
        }
        
        guard let name = self.getNameTextField.text else { // 과목명을 입력했는지 검사 안했으면 경고창 띄우기
            self.openAlert()
            return
        }
        
        if name == ""{
            self.openAlert() // 과목명을 빈칸으로 둬도 경고창!
        }else{
            StopWatchDAO().addSegment(row: row, name: name, date: self.saveDate) // 과목을 DB에 추가하는 메소드
            
            self.navigationController?.popViewController(animated: true) // 전 뷰로 돌아가기
        }
    }
    
    func editCategoryMtd(){
        guard let code = self.selectedColorCode else {
            self.openAlert()
            return
        }
        
        guard let name = self.getNameTextField.text else {
            self.openAlert()
            return
        }
        
        if name == ""{
            self.openAlert()
        }else{
            let segment = self.realm.objects(Segments.self)
            try! self.realm.write{
                segment[selectedSegmentRow!].name = name
                segment[selectedSegmentRow!].colorCode = code
                
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    //MARK: addSubView,AddTarget
    
    func addSubView(){
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.getNameTextField)
        self.view.addSubview(self.colorLabel)
        self.view.addSubview(self.paletteView)
        self.view.addSubview(self.okButton)
        self.view.addSubview(self.cancelButton)
    }
    
    func addTarget(){
        self.okButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
    }
    
    //MARK: Selector
    @objc func buttonTapped(button: UIButton){
        switch button.tag{
        case 1:
            if let _ = self.selectedSegmentRow{
                self.editCategoryMtd() //선택된 세그먼트로우가 있으면 편집
            }else{
                self.addCategoryMtd() // 없으면 새로 추가.
            }
           
        case 2:
            self.navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    @objc func respondToGesture(_ sender: UILongPressGestureRecognizer){
        self.openEditColorView()
        //색상코드 불러오기
        guard let row = sender.view?.tag else { return }
        let object = realm.objects(Palettes.self)[row]
        self.editColorView?.palettes = object
        let colorCode = object.colorCode
        self.editColorView?.addButton.tag = colorCode
        let convertString = String(colorCode, radix: 16).uppercased()
        self.editColorView!.getColorCodeTextfield.text? = convertString
        self.editColorView!.colorPreView.backgroundColor = self.view.uiColorFromHexCode(colorCode)
        
        //버튼 타이틀을 edit으로 수정하고 edit method,delete method 추가
        self.editColorView?.addButton.setTitle("edit", for: .normal)
        self.editColorView?.titleLabel.text = "색상 편집"
        self.editColorView?.addButton.addTarget(self, action: #selector(self.editColor(_:)), for: .touchUpInside)
        self.editColorView?.deleteColrButton.addTarget(self, action: #selector(self.deleteColor(_:)), for: .touchUpInside)
        //delete버튼 보이기
        self.editColorView?.deleteColrButton.isHidden = false
    }
    
    //MARK: - EditColorViewMethod
    //색 저장
    @objc func addColor(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write{
            let newColorCode = Palettes()
            newColorCode.colorCode = sender.tag
            realm.add(newColorCode)
        }
        self.paletteView.reloadData()
        self.editColorView?.removeFromSuperview()
        self.editColorView = nil
    }
    
    @objc func editColor(_ sender: UIButton) {
        try! realm.write{
            guard let object = self.editColorView?.palettes else { return }
            object.colorCode = sender.tag
        }
        self.paletteView.reloadData()
        self.editColorView?.removeFromSuperview()
        self.editColorView = nil
    }
    
    @objc func deleteColor(_ sender: UIButton){
        guard let palette = self.editColorView?.palettes else { return }
        let realm = try! Realm()
        try! realm.write{
            realm.delete(palette)
        }
        self.paletteView.reloadData()
        self.editColorView?.removeFromSuperview()
        self.editColorView = nil
    }
    
    func openEditColorView() {
        guard self.editColorView == nil else { return } // 중복 뷰 방지
        self.editColorView = EditColorView()
        self.view.addSubview(self.editColorView!)
        self.editColorView!.cancelButton.addTarget(self, action: #selector(self.closeColorView(_:)), for: .touchUpInside)
        
        self.editColorView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.editColorView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            self.editColorView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            self.editColorView!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.editColorView!.heightAnchor.constraint(equalToConstant: 170)
        ])
    }

    //닫기
    @objc func closeColorView(_ sender: Any){
        self.editColorView?.removeFromSuperview()
        self.editColorView = nil
    }
    
    //MARK: layout
    func layout(){
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 22)
        ])
        
        NSLayoutConstraint.activate([
            self.getNameTextField.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.getNameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 22),
            self.getNameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -22),
            self.getNameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            self.colorLabel.topAnchor.constraint(equalTo: self.getNameTextField.bottomAnchor, constant: 26),
            self.colorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 22)
        ])
        
        NSLayoutConstraint.activate([
            self.paletteView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 22),
            self.paletteView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -22),
            self.paletteView.topAnchor.constraint(equalTo: self.colorLabel.bottomAnchor, constant: 10),
            self.paletteView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        NSLayoutConstraint.activate([
            self.okButton.topAnchor.constraint(equalTo: self.paletteView.bottomAnchor, constant: 14),
            self.okButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -46),
            self.okButton.widthAnchor.constraint(equalToConstant: 80),
            self.okButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            self.cancelButton.topAnchor.constraint(equalTo: self.paletteView.bottomAnchor, constant: 14),
            self.cancelButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 46),
            self.cancelButton.widthAnchor.constraint(equalToConstant: 80),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    
    }
}
//MARK: - CollectionView Delegate , datasource
extension EditCategoryViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.realm.objects(Palettes.self).count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PaltteCell
        //초기화
        cell.checkImageView.image = UIImage(systemName: "checkmark")
        cell.checkImageView.isHidden = true
        let palettes = self.realm.objects(Palettes.self)
        
        //색상을 추가하는 마지막 셀 구성
        if indexPath.row == palettes.count {
            cell.checkImageView.image = UIImage(systemName: "plus")
            cell.checkImageView.isHidden = false
            cell.paintView.backgroundColor = .systemGray3
        }else { // 팔레트 구성
            //팔레트 색상 구성
            let colorCode = palettes[indexPath.row].colorCode
            cell.paintView.backgroundColor = self.view.uiColorFromHexCode(colorCode)
           
            //선택된 셀이면 체크마크!
            if let row = self.selectedColorRow {
                if indexPath.row == row {
                    cell.checkImageView.isHidden = false
                }
            }
            
            //편집용 제스쳐 추가
            let longPressGeture = UILongPressGestureRecognizer(target: self, action: #selector(self.respondToGesture(_:)))
            cell.addGestureRecognizer(longPressGeture)
            longPressGeture.view?.tag = indexPath.row // 몇번째 셀인지 구분용
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.realm.objects(Palettes.self)
        if indexPath.row == object.count {
            // 색상 추가뷰
            self.openEditColorView()
            self.editColorView!.addButton.addTarget(self, action: #selector(self.addColor(_:)), for: .touchUpInside)
        }else { // 색상 골랐을 때
            self.selectedColorCode = object[indexPath.row].colorCode
            self.selectedColorRow = indexPath.row
            collectionView.reloadData()
        }
    }
}

extension EditCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize( width: 54, height: 54 )
    }
}

//MARK:- UITextFieldDelegate
extension CategoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
