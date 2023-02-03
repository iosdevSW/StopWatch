//
//  EditCategoryViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/14.
//
import UIKit
import RealmSwift
import Then
import SnapKit

final class EditCategoryViewController: UIViewController {
    //MARK: - Properties
    private let realm = try! Realm()
    lazy var palette = realm.objects(Palettes.self)
    
    var selectedColorCode: Int? 
    var selectedSegmentRow: Int?
    var saveDate:String = ""
    
    var editColorView: EditColorView?
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .light)
        $0.textColor = .black
        $0.text = "Name"
    }
    
    private let colorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .light)
        $0.textColor = .black
        $0.text = "Palette"
    }
    
    let getNameTextField = CustomTextField().then {
        $0.font = .systemFont(ofSize: 18, weight: .light)
        $0.textColor = .black
        $0.underLine.backgroundColor = .black
    }
    
    private let paletteView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        
        $0.register(PaltteCell.self, forCellWithReuseIdentifier: "cell")
        $0.backgroundColor = .white
    }
    
    private let okButton = UIButton(type: .roundedRect).then {
        $0.setTitle("OK", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 10
        $0.tag = 1
    }
    
    private let cancelButton = UIButton(type: .roundedRect).then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 10
        $0.tag = 2
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubView()
        self.layout()
        self.addTarget()
        self.view.backgroundColor = .white
        
        self.paletteView.delegate = self
        self.paletteView.dataSource = self
        
        self.hideKeyboardWhenTapped()
        self.setNavigationItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveCloseColorEditView(_:)), name: .closeColorEditView, object: nil)
        
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
    }
    
    //MARK: - Method
    private func setNavigationItem() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Category"
    }
    
    private func addCategoryMtd(){
        guard let code = self.selectedColorCode else { // 색을 정했는지 검사 안했으면 경고창 띄우기
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
            return
        }
        
        guard let name = self.getNameTextField.text else { // 과목명을 입력했는지 검사 안했으면 경고창 띄우기
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
            return
        }
        
        if name == ""{
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
        }else{
            StopWatchDAO().addSegment(row: code, name: name, date: self.saveDate) // 과목을 DB에 추가하는 메소드
            
            self.navigationController?.popViewController(animated: true) // 전 뷰로 돌아가기
        }
    }
    
    private func editCategoryMtd(){
        guard let code = self.selectedColorCode else {
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
            return
        }
        
        guard let name = self.getNameTextField.text else {
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
            return
        }
        
        if name == ""{
            self.notiAlert(title: "경 고", message: "색과 이름을 모두 입력해주세요.")
        }else{
            let segment = self.realm.objects(Segments.self)
            try! self.realm.write{
                segment[selectedSegmentRow!].name = name
                segment[selectedSegmentRow!].colorCode = code
                
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func findColorIndex(_ code: Int?) -> Int? {
        let objects = self.realm.objects(Palettes.self)
        guard let code else { return nil}
        let idx = objects.firstIndex { $0.colorCode == code }
        guard let idx else { return nil }
        
        return idx
    }
    
    //MARK: - Selector
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
    
    @objc func didRecieveLongPressGesture(_ sender: UILongPressGestureRecognizer){
        guard let row = self.paletteView.indexPathForItem(at: sender.location(in: self.paletteView))?.row else { return}
        self.openEditColorView(.edit, palette: self.palette[row])
    }
    
    //MARK: - EditColorViewMethod    
    func openEditColorView(_ mode: ColorViewMode, palette: Palettes?) {
        guard self.editColorView == nil else { return } // 중복 뷰 방지
        self.editColorView = EditColorView(mode, palette).then {
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
                make.centerY.equalToSuperview()
                make.height.equalTo(170)
            }
        }
    }

    @objc private func didRecieveCloseColorEditView(_ sender: Any){
        self.paletteView.reloadData()
        self.editColorView?.removeFromSuperview()
        self.editColorView = nil
    }
    
    //MARK: - AddSubView
    private func addSubView(){
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.getNameTextField)
        self.view.addSubview(self.colorLabel)
        self.view.addSubview(self.paletteView)
        self.view.addSubview(self.okButton)
        self.view.addSubview(self.cancelButton)
    }
    
    //MARK: - Layout
    private func layout(){
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(22)
        }
        
        self.getNameTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.equalTo(50)
        }
        
        self.colorLabel.snp.makeConstraints {
            $0.top.equalTo(self.getNameTextField.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(22)
        }
        
        self.paletteView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.top.equalTo(self.colorLabel.snp.bottom).offset(10)
            $0.height.equalTo(220)
        }
        
        self.okButton.snp.makeConstraints {
            $0.top.equalTo(self.paletteView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview().offset(-46)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
        
        self.cancelButton.snp.makeConstraints {
            $0.top.equalTo(self.paletteView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview().offset(46)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget(){
        self.okButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
    }
}
//MARK: - CollectionView Delegate , datasource
extension EditCategoryViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.palette.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PaltteCell
        //초기화
        cell.prepareForReuse()
        
        //색상을 추가하는 마지막 셀 구성
        if indexPath.row == palette.count {
            cell.checkImageView.image = UIImage(systemName: "plus")
            cell.checkImageView.isHidden = false
            cell.paintView.backgroundColor = .systemGray3
        }else { // 팔레트 구성
            //팔레트 색상 구성
            let colorCode = palette[indexPath.row].colorCode
            cell.paintView.backgroundColor = self.view.uiColorFromHexCode(colorCode)
           
            //선택된 셀이면 체크마크!
            if let row = self.findColorIndex(self.selectedColorCode) {
                cell.checkImageView.isHidden = indexPath.row == row ? false : true
            }
            
            //편집용 제스쳐 추가
            let longPressGeture = UILongPressGestureRecognizer(target: self, action: #selector(self.didRecieveLongPressGesture(_:)))
            cell.addGestureRecognizer(longPressGeture)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.realm.objects(Palettes.self)
        if indexPath.row == object.count {
            // 색상 추가뷰
            self.openEditColorView(.add, palette: nil)
        }else { // 색상 골랐을 때
            self.selectedColorCode = object[indexPath.row].colorCode
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
