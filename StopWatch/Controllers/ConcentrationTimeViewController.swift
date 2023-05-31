//
//  ConcentrationTimeViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/29.
//
//
import UIKit
import RealmSwift
import CoreData

final class ConcentrationTimeViewController: UIViewController{
    //MARK: - Properties
    private let realm = try! Realm()

    private var timeInterval: TimeInterval = 0.0
    
    private var pickCategoryRow = 0
    private var blackViewController: BlackViewController?
    
    private var resetDate = "" // 초기화 시간 기준 날짜
    
    private lazy var modalView = TimeSaveModalView()
    
    private lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private let frameView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let guideLabel = UILabel().then {
        $0.text = "다시 시작하시려면 핸드폰을 뒤집어주세요."
        $0.textColor = .systemGray4
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
        $0.layer.cornerRadius = 10
        $0.numberOfLines = 2
    }
    
    private lazy var pickerCategory = UIPickerView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemGray6
    }
    
    private let mainLabel = TimeLabel(.hms).then {
        $0.font = .systemFont(ofSize: 50, weight:.regular)
    }
    
    private let acceptButton = UIButton(type: .system).then {
        $0.setTitle(" 확 인 ", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = .zero
        $0.layer.backgroundColor = UIColor.white.cgColor
    }
    
    private let topLineView = UIView().then {
        $0.alpha = 0.7
        $0.backgroundColor = .darkGray
    }
 
    private let bottomLineView = UIView().then {
        $0.alpha = 0.7
        $0.backgroundColor = .darkGray
    }
    
    private let addCategoryButton = UIButton(type: .system).then {
        let title = "원하는 카테고리가 없으신가요?"
        let attributedTitle = NSMutableAttributedString(string: title)
        let range = NSRange(location: 0, length: title.count)
        attributedTitle.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue,
                                       .foregroundColor : UIColor.systemGray2,
                                       .font : UIFont.systemFont(ofSize: 14, weight: .semibold)],
                                      range: range)
        
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    //MARK: - Method
    deinit {
        print("--------------ConcetrationTimeViewCotroller deinit----------")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.openBlackView()
        
        self.pickerCategory.delegate = self
        self.pickerCategory.dataSource = self
        
        self.resetDate = (UIApplication.shared.delegate as! AppDelegate).resetDate
        
        StopWatchDAO().createDailyData(self.resetDate)
        
        self.changeUIColor(row: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pickerCategory.reloadAllComponents()
    }
    
    private func setTimeLabel(){
        self.mainLabel.updateTime(self.view.divideSecond(timeInterval: self.timeInterval ))
    }
    
    private func openTimeSaveModalView() {
        let categoryName = self.realm.objects(Segments.self)[self.pickCategoryRow].name
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.modalView)
        
        self.modalView.alpha = 0
        self.blurView.alpha = 0
        self.modalLayout()
        
        self.modalView.delegate = self
        self.modalView.guideLabel.text = "'\(categoryName)'에 저장하시겠습니까?"
        
        UIView.animate(withDuration: 0.3){
            self.blurView.alpha = 1
            self.modalView.alpha = 1
        }
    }
    
    private func changeUIColor(row: Int) {
        let segment = self.realm.objects(Segments.self)[row]

        self.topLineView.backgroundColor = self.view.uiColorFromHexCode(segment.colorCode)
        self.bottomLineView.backgroundColor = self.view.uiColorFromHexCode(segment.colorCode)
        self.pickerCategory.backgroundColor = self.view.uiColorFromHexCode(segment.colorCode)
    }
    
    private func closeTimeSaveModalView() {
        if let stopWatchVC = self.navigationController?.viewControllers[0] as? StopWatchViewController {
            stopWatchVC.setTimeLabel()
            stopWatchVC.concentraionTimerVC = nil
        }
        
        guard let data = StopWatchDAO().getDailyData(self.resetDate) else { return }// 오늘 과목
        
        StopWatchDAO().addTotalTime(self.timeInterval, data: data, row: self.pickCategoryRow)
        
        self.cancelModalView()
        
        navigationController?.popViewController(animated: true)
    }
    
    func openBlackView() {
        guard self.blackViewController == nil else { return }
        self.blackViewController = BlackViewController().then {
            $0.delegate = self
            $0.modalPresentationStyle = .fullScreen
        }
        
        present(self.blackViewController!, animated: true, completion: nil)
    }
    
    func closeBlackView(){
        guard let _ = self.blackViewController else { return }
            dismiss(animated: true, completion: nil)
            self.blackViewController = nil
    }
    
    //MARK: - Selector
    @objc func acceptButtonMtd(){
        self.openTimeSaveModalView()
    }
    
    @objc func addCategoryButtonMtd(){
        let editVC = EditCategoryViewController()
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
}

extension ConcentrationTimeViewController {
    //MARK: - Configured
    private func configure(){
        self.view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - AddTarget
    private func addTarget(){
        self.acceptButton.addTarget(self, action: #selector(self.acceptButtonMtd), for: .touchUpInside)
        self.addCategoryButton.addTarget(self, action: #selector(self.addCategoryButtonMtd), for: .touchUpInside)
    }
    
    //MARK: - AddSubView
    private func addSubView(){
        self.view.addSubview(self.frameView)
        self.view.addSubview(self.mainLabel)
        self.view.addSubview(self.acceptButton)
        self.view.addSubview(self.pickerCategory)
        self.view.addSubview(self.guideLabel)
        self.view.addSubview(self.addCategoryButton)
        
        self.view.addSubview(self.topLineView)
        self.view.addSubview(self.bottomLineView)
    }
    
    //MARK: - Layout
    private func layout(){
        self.frameView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(140)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-60)
            $0.height.equalTo(100)
        }
        
        self.pickerCategory.snp.makeConstraints {
            $0.top.equalToSuperview().offset(160)
            $0.height.equalTo(100)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        self.acceptButton.snp.makeConstraints {
            $0.top.equalTo(self.mainLabel.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(50)
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.top.equalTo(self.acceptButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.view.frame.width-120)
            $0.height.equalTo(60)
        }
        
        self.mainLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.frameView.snp.bottom).offset(80)
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(80)
        }
        
        self.addCategoryButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.centerX.equalToSuperview()
        }
        
        self.topLineView.snp.makeConstraints {
            $0.top.equalTo(self.mainLabel.snp.top).offset(-10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(2)
        }
        
        self.bottomLineView.snp.makeConstraints {
            $0.bottom.equalTo(self.mainLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(2)
        }
    }
    
    private func modalLayout(){
        self.blurView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.modalView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(self.view.frame.width - 80)
            $0.height.equalTo(200)
        }
    }
}

extension ConcentrationTimeViewController: TimeSaveModalViewDelegate{
    func exitModalView() {
        if let stopWatchVC = self.navigationController?.viewControllers[0] as? StopWatchViewController {
            stopWatchVC.setTimeLabel()
            stopWatchVC.concentraionTimerVC = nil
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func closeModalView() {
        self.closeTimeSaveModalView()
    }
    
    func cancelModalView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0
            self.modalView.alpha = 0
        }){(_) in
            self.modalView.removeFromSuperview()
            self.blurView.removeFromSuperview()
            self.modalView.delegate = nil
        }
    }
}

extension ConcentrationTimeViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 컴포넌트 개수
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.realm.objects(Segments.self).count // 피커뷰 로우 개수
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickCategoryRow = row // 카테고리 선택했을때 호출
        self.changeUIColor(row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = self.realm.objects(Segments.self)[row].name // 피커뷰 카테고리 이름 설정
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.view.frame.width - 60
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

//timer가 멈출 때
extension ConcentrationTimeViewController: TimerTriggreDelegate{
    func timerStop(_ startDate: TimeInterval) {
        let result = Date().timeIntervalSince1970 - startDate
        self.timeInterval += result
        self.setTimeLabel()
    }
}
