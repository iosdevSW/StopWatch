//
//  ConcentrationTimeViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/29.
//
//
import UIKit
import RealmSwift

private let reuseIdentifier = "Cell"

class ConcentrationTimeViewController: UIViewController{
    //MARK: Properties
    var startDate:TimeInterval = 0.0
    var timeInterval: TimeInterval = 0.0
    var totalTime: TimeInterval = 0.0
    var pickCategoryRow = 0
    var blackViewController: BlackViewController?
    var saveDate = ""
    let realm = try! Realm()
    
    let frameView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Focus Time"
        label.font = UIFont(name: "Zapf Dingbats", size: 30)
        label.textAlignment = .center
        label.textColor = .darkGray
        
        
        return label
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "다시 시작하시려면 핸드폰을 뒤집어주세요."
        label.textColor = .systemGray4
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.layer.cornerRadius = 10
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var pickerCategory: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pickerView)
        pickerView.layer.cornerRadius = 10
        pickerView.backgroundColor = .systemGray6
        
        
        return pickerView
    }()
    
    lazy var mainLabel: UILabel = {
        let label = UILabel()
        
//        label.layer.borderWidth = 2
        label.text = "00 : 00 : 00"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.backgroundColor = .white
        label.textColor = .darkGray
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 0.3
        label.font = .systemFont(ofSize: 50, weight:.regular)
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
//        self.mainLabel.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var aceptButton: UIButton = {
        let button = UIButton()
        button.setTitle(" 확 인 ", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.borderWidth = 1
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = .zero
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.backgroundColor = UIColor.white.cgColor
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var modalView: StopButtonTappedModalView = {
        let modalView = StopButtonTappedModalView()
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        return modalView
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    lazy var bottomview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.backgroundColor = .darkGray
        view.alpha = 0.7
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.mainLabel.bottomAnchor, constant: 10),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            view.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.backgroundColor = .darkGray
        view.alpha = 0.7
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.mainLabel.topAnchor, constant: -10),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            view.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        return view
    }()
    
    //MARK: Method
    
    deinit {
        print("--------------ConcetrationTimeViewCotroller deinit----------")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.openBlackView()
        self.addSubView()
        self.layOut()
        self.addTarget()
        self.startDate = Date().timeIntervalSince1970
        self.pickerCategory.delegate = self
        self.pickerCategory.dataSource = self
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
        self.totalTime = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.totalTime ?? 0
        self.navigationController?.navigationBar.isHidden = true
        StopWatchDAO().create(date: self.saveDate) // 오늘 데이터 없으면 생성
        //vibrate iphone when the timer starts
        self.changeUI(row: 0)
     
    }
    override func viewWillAppear(_ animated: Bool) {
//        print("viewWillappear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        //timer start
//        self.generatePhone()
        
    }
    
    func setTimeLabel(){
        let (subSecond,second,minute,hour) = self.view.divideSecond(timeInterval: self.timeInterval )
        self.subLabel.text = subSecond
        self.mainLabel.text = "\(hour) : \(minute) : \(second)"
    }
    
    func openStopModalView(){
        let categoryName = self.realm.objects(Segments.self)[pickCategoryRow].name
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
    
    func changeUI(row: Int) {
        let segment = self.realm.objects(Segments.self)
        self.label.text = segment[row].name
//        self.label.textColor = .white
//        self.frameView.backgroundColor = self.uiColorFromHexCode(segment[row].colorCode)
        self.topView.backgroundColor = self.view.uiColorFromHexCode(segment[row].colorCode)
        self.bottomview.backgroundColor = self.view.uiColorFromHexCode(segment[row].colorCode)
//        self.mainLabel.textColor = self.uiColorFromHexCode(segment[row].colorCode)
        self.pickerCategory.backgroundColor = self.view.uiColorFromHexCode(segment[row].colorCode)
    }
    
    func closeStopModalView(){
        if let stopWatchVC = self.navigationController?.viewControllers[0] as? StopWatchViewController {
            stopWatchVC.setTimeLabel()
            stopWatchVC.concentraionTimerVC = nil
        }
        let segments = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate) // 오늘 과목
        try! self.realm.write{
            segments?.dailySegment[pickCategoryRow].value += self.timeInterval //선택한 과목에 시간 추가
            var totalTime: TimeInterval = 0
            for segValue in segments!.dailySegment {
                totalTime += segValue.value
            }
            segments?.totalTime = totalTime
        }
        
        self.cancelModalView()
        
        navigationController?.popViewController(animated: true)
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
    
    func openBlackView(){
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.blackViewController == nil {
            self.blackViewController = BlackViewController()
            self.blackViewController?.delegate = self
            self.blackViewController!.view.backgroundColor = .black
            self.blackViewController?.modalPresentationStyle = .fullScreen
            present(self.blackViewController!, animated: true, completion: nil)
        }
    }
    
    
    func closeBlackView(){
        if let _ = self.blackViewController{
            dismiss(animated: true, completion: nil)
            self.blackViewController = nil
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
        }
    }
    
    //MARK: Selector
    @objc func aceptButtonMtd(){
        self.openStopModalView()
    }
    
}
extension ConcentrationTimeViewController {
    //MARK: Configured
    func configure(){
        self.view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
    }
    
    //MARK: AddTarget
    func addTarget(){
        self.aceptButton.addTarget(self, action: #selector(aceptButtonMtd), for: .touchUpInside)
    }
    //MARK: AddSubView
    func addSubView(){
        self.view.addSubview(self.frameView)
        self.view.addSubview(self.guideLabel)
        
        self.frameView.addSubview(self.label)
    }
    
    //MARK: LayOut
    func layOut(){
        //Level 1
        NSLayoutConstraint.activate([
            self.frameView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 140),
            self.frameView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60),
            self.frameView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -60),
            self.frameView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            self.mainLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.mainLabel.topAnchor.constraint(equalTo: self.frameView.bottomAnchor, constant: 80),
            self.mainLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 80),
            self.mainLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            self.aceptButton.topAnchor.constraint(equalTo: self.mainLabel.bottomAnchor, constant: 60),
            self.aceptButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.aceptButton.widthAnchor.constraint(equalToConstant: 160),
            self.aceptButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            self.pickerCategory.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 160),
            self.pickerCategory.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.pickerCategory.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            self.guideLabel.topAnchor.constraint(equalTo: self.aceptButton.bottomAnchor, constant: 20),
            self.guideLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.guideLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 120),
            self.guideLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        //Level 2
        NSLayoutConstraint.activate([
            self.label.centerYAnchor.constraint(equalTo: self.frameView.centerYAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.frameView.centerXAnchor),
            ])
//
//        NSLayoutConstraint.activate([
//            self.subLabel.centerYAnchor.constraint(equalTo: self.mainLabel.centerYAnchor, constant: 3),
//            self.subLabel.trailingAnchor.constraint(equalTo: self.mainLabel.trailingAnchor, constant: -16),
//        ])
    }
    func modalLayout(){
        
        NSLayoutConstraint.activate([
            self.blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.modalView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.modalView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.modalView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 80),
            self.modalView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
extension ConcentrationTimeViewController: StopModalViewDelegate{
    func closeModalView() {
        self.closeStopModalView()
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
        self.changeUI(row: row
        )
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
        self.startDate = startDate
        let result = Date().timeIntervalSince1970 - self.startDate
        self.timeInterval += result
        self.setTimeLabel()
    }
}
