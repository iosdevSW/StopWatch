//
//  StopWatchViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/29.
//

import UIKit
import CoreMotion
import RealmSwift
import Then
import SnapKit

final class StopWatchViewController: UIViewController {
    //MARK: - Properties
    //전체 시간, 전체 목표시간 저장 프로퍼티
    var totalTime: TimeInterval = 0
    var totalGoalTime: TimeInterval = 0

    let realm = try! Realm()
    var motionManager: CMMotionManager?
    
    var concentraionTimerVC: ConcentrationTimeViewController?
    var editTodoListView: EditTodoListView?
    var editGoalTimeView: EditGoalTimeView?
    var chartView: ChartView?
    var guideLabelView: GuideLabelView?
    var tapView: UIView?
    
    var tapGesture: UITapGestureRecognizer?
    var timer: Timer?
    
    var delegate: StopWatchVCDelegate?
    var saveDateDelegate: SaveDateDetectionDelegate?
    
    var calendarViewHeight: NSLayoutConstraint!
    var frameViewHeight: NSLayoutConstraint!
    
    // true : week, false : month
    var calendarMode = true {
        didSet {
            if self.calendarMode {
                self.guideLabelView?.isHidden = false
            }else {
                self.guideLabelView?.isHidden = true
            }
        }
    }
    
    var saveDate: String = "" {
        didSet{ // 날짜가 바뀔 때마다
            self.setGoalTime() // 목표시간 Label 재설정
            self.reloadProgressBar() // 진행바 재로딩
            self.setTimeLabel() // 현재시간 Label 재설정
            self.titleView.label.text = CalendarMethod().convertDate(date: self.saveDate) // 타이틀 날짜 다시표시
            self.toDoTableView.reloadData()
            self.calendarView.saveDate = self.saveDate
            self.calendarView.calendarView.reloadData()
        }
    }
    
    private let titleView = TitleView()
    private let goalTimeView = GoalTimeView()
    private let barView = DrawBarView()
    
    private let calendarView = CalendarView().then {
        $0.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
        $0.presentDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
        $0.backgroundColor = .blue
    }
    
    private let previousMonthButton = UIButton(type: .system).then {
        $0.tag = 0
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = .darkGray
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let nextMonthButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        $0.tintColor = .darkGray
        $0.tag = 1
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let changeCalendarMode = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("주▾", for: .normal)
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
        $0.setTitleColor(UIColor.darkGray, for: .normal)
    }
        
    let frameView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 50
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    let itemBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let mainTimeLabel = TimeLabel(.hms).then {
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 50, weight: .regular)
    }
    
    let chartViewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.setImage(UIImage(systemName: "chart.pie.fill"), for: .normal)
        button.tintColor = .darkGray
        button.layer.cornerRadius = 10
    
        return button
    }()
    
    let dDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Times New Roman", size: 16)
        label.textColor = .darkGray
        label.text = "-days left"
        
        return label
    }()
    
    let toDoTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.register(TodoListCell.self, forCellReuseIdentifier: "cell")
        view.separatorStyle = .none
        view.bounces = false
        view.showsVerticalScrollIndicator = false
        if #available(iOS 15, *) {
            view.sectionHeaderTopPadding = 0
        }
        
        return view
    }()
    
    private let categoryEditButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        $0.tintColor = .darkGray
        $0.tag = 2
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configured()   // 뷰 초기 설정 메소드
        self.addSubView()   // 서브뷰 추가 메소드
        self.layOut()       // 레이이웃 메소드
        self.addTarget()
        self.calendarView.delegate = self
        self.toDoTableView.delegate = self
        self.toDoTableView.dataSource = self
        self.hideKeyboardWhenTapped() //
        self.addObserverMtd() // 옵저버 추가
        self.reloadProgressBar()
        print("path =  \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 프로퍼티 값 갱신
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).resetDate //오늘 날짜!
        self.totalTime = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.totalTime ?? 0
        self.totalGoalTime = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.totalGoalTime ?? 0
        
        self.setDeviceMotion()   // coremotion 시작
        self.reloadProgressBar() // 진행바 재로딩
        self.setNavigationBar()  // 네비게이션바 설정
        self.setDday()
        if self.calendarMode { self.animateGuideLabel() } // 가이드 레이블 표시
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.autoScrollCurrentDate()
        
        if self.guideLabelView != nil{
            UIView.transition(with: self.guideLabelView!, duration: 3, options: [.repeat, .transitionFlipFromTop], animations: nil, completion: nil)
        }
    }
    
    //MARK: - Method
    func autoScrollCurrentDate(){
        let itemIndex = CalendarMethod().returnIndexOfDay(date: self.saveDate)
        self.calendarView.calendarView.scrollToItem(at: IndexPath(item: itemIndex - 1, section: 0), at: .left, animated: true)
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationItem.backButtonTitle = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.motionManager?.stopDeviceMotionUpdates()
    }
    
    func reloadProgressBar(){
        let object = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        self.totalGoalTime = object?.totalGoalTime ?? 0
        self.totalTime = object?.totalTime ?? 0
        self.barView.per =
            self.totalGoalTime != 0 ? Float(self.totalTime / self.totalGoalTime): 0
        self.barView.progressView.setProgress(self.barView.per, animated: true)
        
        self.barView.showPersent()
        
    }
    
    func setTimeLabel(){
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let time = dailyData?.totalTime ?? 0 // 오늘의 데이터가 없으면 0
        self.mainTimeLabel.updateTime(self.view.divideSecond(timeInterval: time))
    }
    
    func setGoalTime(){
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let goal = dailyData?.totalGoalTime ?? 0 // 오늘의 데이터가 없으면 0
        self.goalTimeView.timeLabel.updateTime(self.view.divideSecond(timeInterval: goal))
    }
    
    //MARK: - gestrue method
    func setSwipeGesture(){
        //차트뷰 아래로 내려서 닫기 제스쳐 추가
        if let view = self.chartView {
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
            downSwipe.direction = .down
            view.addGestureRecognizer(downSwipe)
        }
    }
    
    // 가이드레이블 애니메이트
    func animateGuideLabel() {
        if self.guideLabelView != nil{
            self.guideLabelView?.removeFromSuperview()
            self.guideLabelView = nil
            self.timer?.invalidate()
            self.timer = nil
        }
        
        // 애니메이트 시작
        self.guideLabelView = {
            let view = GuideLabelView()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.heightAnchor.constraint(equalToConstant: 30)
            ])

            return view
        }()
        
        var count = 0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ timer in
            count += 1
            // 4 번 실행되면 중지
            if count == 4 {
                UIView.animate(withDuration: 1){
                    self.guideLabelView?.removeFromSuperview()
                    self.guideLabelView = nil
                }
                self.timer?.invalidate()
                self.timer = nil
            }
        }

    
    }
    
    // 서브뷰가 떠있을때 외부 뷰 탭
    func setTapGesture(){
        guard tapView == nil else { return }
        self.tapView = {
            let tapView = UIView()
            self.view.addSubview(tapView)
            tapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture(_:)))
            tapView.addGestureRecognizer(self.tapGesture!)
            
            return tapView
        }()
    }
    
    func zeroTimeAlert(){
        let alert = UIAlertController(title: "알 림", message: "측정된 시간이 없습니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // subview open method
    func openChartView(){
        if self.chartView != nil { return }

        self.chartView = {
            let view = ChartView()
            view.saveDate = self.saveDate
            view.translatesAutoresizingMaskIntoConstraints = false
            self.frameView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor)
            ])
            
            return view
        }()
        
        self.setSwipeGesture()
        self.chartView!.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        UIView.animate(withDuration: 0.5){
            self.chartView!.transform = .identity
        }
    }
    
    // 차트 뷰 닫는 함수
    func closeChartView(){
        if let modal = self.chartView {
            UIView.animate(withDuration: 0.5 ,animations: {
                modal.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }) {_ in
                modal.removeFromSuperview()
                self.chartView = nil
            }
        }
    }
    
    func setDday(){
        let ud = UserDefaults.standard
        let day = ud.value(forKey: "dday") as? Date ?? Date()
        let dayCount = Double(day.timeIntervalSinceNow / 86400) // 하루86400초
        let dday =  Int(ceil(dayCount)) // 소수점 올림
        if dday > 0 {
            self.dDayLabel.text = "\(dday) days left"
        }else if dday == 0 {
            self.dDayLabel.text = "D-Day"
        }else {
            self.dDayLabel.text = "It's been \(abs(dday)) days."
        }
        
       
    }
    
    //MARK: - Selector
    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer){
        switch gesture.direction {
        case .down:
            self.closeChartView()
        default:
            break
        }
    }
    
    @objc func respondToButton(_ button:UIButton){
        let (year,month,day) = CalendarMethod().changeMonth(tag: button.tag, date: self.calendarView.presentDate)
        
        self.calendarView.presentDate = String(year) + "." + self.view.returnString(month) + "." + self.view.returnString(day)
        
        // 바뀐 값 캘린더뷰로 전달하고 컬렉션뷰 리로드
        self.calendarView.saveDate = self.saveDate
        self.calendarView.calendarView.reloadData()
        self.autoScrollCurrentDate()
        self.titleView.label.text = CalendarMethod().convertDate(date: self.calendarView.presentDate) // 타이틀 날짜 다시표시
        self.saveDateDelegate?.detectSaveDate(date: self.saveDate)
    }

    //주 <-> 월 달력 변경 버튼 클릭
    @objc func changeCalendarMode(_ sender: UIButton){
        UIView.animate(withDuration: 0.5){
            if self.calendarMode {
                self.calendarView.calendarMode = .month
                self.calendarViewHeight.isActive = false
                self.frameViewHeight.isActive = false
                self.frameViewHeight = self.frameView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.86)
                self.calendarViewHeight = self.calendarView.heightAnchor.constraint(equalToConstant: 220)

                self.mainTimeLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.dDayLabel.alpha = 0
                self.changeCalendarMode.setTitle("월▾", for: .normal)

                self.calendarViewHeight.isActive = true
                self.frameViewHeight.isActive = true
                self.mainTimeLabel.layoutIfNeeded()

                self.chartView?.labelConstraint.isActive = false
                self.chartView?.labelConstraint.constant = 0
                self.chartView?.labelConstraint.isActive = true
                self.chartView?.layoutIfNeeded()
            }else {
                self.calendarView.calendarMode = .week
                self.calendarViewHeight.isActive = false
                self.frameViewHeight.isActive = false

                self.calendarViewHeight = self.calendarView.heightAnchor.constraint(equalToConstant: 66)

                self.frameViewHeight = self.frameView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.76)
                self.mainTimeLabel.font = .systemFont(ofSize: 50, weight: .regular)
                self.mainTimeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.dDayLabel.alpha = 1
                self.changeCalendarMode.setTitle("주▾", for: .normal)

                self.calendarViewHeight.isActive = true
                self.frameViewHeight.isActive = true
                self.mainTimeLabel.layoutIfNeeded()

                self.chartView?.labelConstraint.isActive = false
                self.chartView?.labelConstraint.constant = 30
                self.chartView?.labelConstraint.isActive = true
                self.chartView?.layoutIfNeeded()

            }
            self.chartView?.setNeedsDisplay() // 차트 뷰 다시그리기
            self.calendarMode = !self.calendarMode
        }
        
    }
    
    @objc func proximityChangedMtd(sender: Notification){
        let isTrue = UIDevice.current.isProximityMonitoringEnabled
        if UIDevice.current.proximityState && isTrue {
        }else{
            self.setDeviceMotion()
        }
    }
    
    func closeGoalTimeEditView() {
        if let _editGoalTimeView = self.editGoalTimeView {
            UIView.animate(withDuration: 0.5,animations: {
                _editGoalTimeView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }){_ in
                StopWatchDAO().deleteSegment(date: self.saveDate)
                _editGoalTimeView.removeFromSuperview()
                self.editGoalTimeView = nil
                self.removeTapView()
            }
        }
    }
    
    //목표 시간 설정 뷰 열기
    func openGoalTimeEditView() {
        guard self.editGoalTimeView == nil else { return } // 이미 객체가 생성되었으면 더 못생성되게 막기
        
        self.editGoalTimeView = {
            let view = EditGoalTimeView()
            self.setTapGesture()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
            view.layer.shadowOpacity = 0.7
            view.layer.shadowOffset = .zero
            view.layer.shadowColor = UIColor.darkGray.cgColor
            
            view.cancelButton.addTarget(self, action: #selector(self.didFinishEditingGoalTime(_:)), for: .touchUpInside)
            view.okButton.addTarget(self, action: #selector(self.didFinishEditingGoalTime(_:)), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
                view.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            return view
        }()
        
        self.editGoalTimeView!.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        UIView.animate(withDuration: 0.3){
            self.editGoalTimeView!.transform = .identity
        }
        StopWatchDAO().create(date: self.saveDate) // 오늘 데이터가 없으면 데이터 생성
        
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)!
        let goal = dailyData.totalGoalTime
        let hourIndex = Int(goal / 3600) % 24 // 3600초 (1시간)으로 나눈 몫을 24로 나누면 시간 인덱스와 같다.
        let miniuteIndex = ((Int(goal) % 3600 ) / 60) / 5 // 남은 분을 5로 나누면 5분간격의 분 인덱스와 같다.
        
        self.editGoalTimeView!.timePicker.selectRow(hourIndex, inComponent: 0, animated: false) //시간초기값
        self.editGoalTimeView!.timePicker.selectRow(miniuteIndex, inComponent: 1, animated: false)//분초기값
        self.editGoalTimeView!.selectedMinute = TimeInterval(Int(goal) % 3600)
        self.editGoalTimeView!.selectedHour = goal - self.editGoalTimeView!.selectedMinute
    }
    
    // 목표 시간 설정 뷰 닫기
    @objc func didFinishEditingGoalTime(_ sender: UIButton){
        if sender.tag == 1 { // 확인버튼
            let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
            try! self.realm.write{
                dailyData!.totalGoalTime =
                    self.editGoalTimeView!.selectedHour + self.editGoalTimeView!.selectedMinute
            }
            self.setGoalTime()
            self.reloadProgressBar()
            
            self.closeGoalTimeEditView()
           
        }
        //취소버튼
        if sender.tag == 2 {
            self.closeGoalTimeEditView()
        }
    }
    
    @objc func clickToChartButton(){
        if self.chartView == nil {
            self.openChartView()
        }else {
            self.closeChartView()
        }
    }
    
    @objc func pushCategoryVC(_ button: UIBarButtonItem){
        self.delegate?.handleMenuToggle(menuOption: nil)
        
    }
    
    //세션(과목명)을 눌렀을때 호출되는 메소드
    @objc func clickedSection(_ sender: UIButton){
        StopWatchDAO().create(date: self.saveDate) // 오늘 데이터가 없으면 데이터 생성
        
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)!
        let segments = dailyData.dailySegment // 오늘 과목들
        let section = sender.tag //section번째 과목 인덱스
        // 그 날의 과목 데이터가 있는지 체크
        
        let toDoList = segments[section].toDoList // section번째 과목의 할 일들

        let row = toDoList.count // section번째 과목의 할 일 번호
        let indexPath = IndexPath(row: row, section: section )

        
        try! self.realm.write{
            toDoList.append("")
            segments[section].listCheckImageIndex.append(0)
        }

        self.toDoTableView.reloadData()
        self.toDoTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        self.calendarView.calendarView.reloadData()
        
        let cell = self.toDoTableView.cellForRow(at:indexPath) as? TodoListCell
        
        cell?.getListTextField.becomeFirstResponder()
       
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        //키보드 정보 불러오기
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.view.bounds.origin = CGPoint(x: 0, y: keyboardHeight - (self.goalTimeView.frame.height)*2 - self.barView.frame.height + 4)
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn){
            self.view.bounds.origin = .zero
        }
    }
    
    func openCategoryVC() {
        let categoryVC = CategoryViewController()
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //탭 제스쳐를 감지하여 뷰를 닫는 액션함수
    @objc func respondToTapGesture(_ sender: Any){
        //편집 뷰가 열려 있으면 편집 뷰 닫기
        self.closeListEditView()
        
        //골타임설정 뷰가 열려 있으면 닫기
        self.closeGoalTimeEditView()

    }
    
    func removeTapView(){
        if self.tapView != nil {
            // 탭 제스쳐 제거
            self.view.removeGestureRecognizer(self.tapGesture!)
            self.tapGesture = nil
            // 탭뷰 제거
            self.tapView?.removeFromSuperview()
            self.tapView = nil
        }
        
    }
    
    //MARK: CalendarView method
    
    func clickDay(saveDate: String) {
        self.saveDate = saveDate
        self.chartView?.saveDate = saveDate
        self.chartView?.setNeedsDisplay() // 다시 차트ㅡ 그리기
    }
    
    //MARK: - SideBarMenu Method
    // 메뉴 터치에 따라 반응하는 함수
    func didSelectedMenuOption(menuOption: MenuOption){
        switch menuOption {
        case .category:
            let categoryVC = CategoryViewController()
            self.navigationController?.pushViewController(categoryVC, animated: true)
        case .goalTime:
            self.openGoalTimeEditView()
        case .dDay:
            let ddayVC = DdayViewController()
            self.navigationController?.pushViewController(ddayVC, animated: true)
        case .statistics:
//            let statisticsVC = StatisticsViewController()
//            self.saveDateDelegate = statisticsVC
//            statisticsVC.navigationItem.title = CalendarMethod().convertDate(date: self.saveDate)
//            self.navigationController?.pushViewController(statisticsVC, animated: true)
//            statisticsVC.previousMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
//            statisticsVC.nextMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
            print("준비중")
            
        }
    }
}

extension StopWatchViewController {
    
    //MARK: Configured
    func configured() {
        self.view.backgroundColor = .clear
    }
    
    //타이머 구동 방식
    func setDeviceMotion(){
        // 메뉴 닫기
        self.delegate?.closeMenu()
        
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 0.1;
        self.motionManager?.startDeviceMotionUpdates(to: .main){
            (motion, error) in
            
            //get proximity state!
            let proximityState = UIDevice.current.proximityState
            //get radian
            guard let attitude = motion?.attitude else{
                print("motion error")
                return }

            let radian = abs(attitude.roll * 180.0 / Double.pi) //코어 모션 회전각도!
            if radian >= 100{ //proxitmiysensor On 
                UIDevice.current.isProximityMonitoringEnabled = true
               
                if radian >= 160 { // timer start
                    if proximityState == true {
                        if self.concentraionTimerVC != nil {
                            self.concentraionTimerVC!.openBlackView()
                        }else{
                            self.concentraionTimerVC = ConcentrationTimeViewController()
                            self.navigationController?.pushViewController(self.concentraionTimerVC!, animated: false)
                        }
                        self.motionManager?.stopDeviceMotionUpdates()
                        
                    }
                }
                
            } else if radian < 100 { //timer stop
                if proximityState == false {
                    UIDevice.current.isProximityMonitoringEnabled = false
                    if let timerVC = self.concentraionTimerVC{
                        timerVC.closeBlackView()
                    }
                }
            }
        }
    }
    
    //MARK: AddSubView
    func addSubView(){
        self.view.addSubview(self.frameView)
        self.view.addSubview(self.dDayLabel)
        self.view.addSubview(self.mainTimeLabel)
        
        self.frameView.addSubview(self.titleView)
        self.frameView.addSubview(self.changeCalendarMode)
        self.frameView.addSubview(self.calendarView)
        self.frameView.addSubview(self.previousMonthButton)
        self.frameView.addSubview(self.nextMonthButton)
        self.frameView.addSubview(self.barView)
        self.frameView.addSubview(self.toDoTableView)
        self.frameView.addSubview(self.goalTimeView)
        self.frameView.addSubview(self.itemBoxView)
        
        self.itemBoxView.addSubview(self.chartViewButton)
        self.itemBoxView.addSubview(self.categoryEditButton)
    }
    
    //MARK: SetLayOut
    func layOut(){
        //Level 1
        self.mainTimeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.frameView.snp.top)
        }
        
        self.frameView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.frameViewHeight = self.frameView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.76)
        self.frameViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            self.changeCalendarMode.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -30),
            self.changeCalendarMode.centerYAnchor.constraint(equalTo: self.titleView.centerYAnchor),
            self.changeCalendarMode.heightAnchor.constraint(equalToConstant: 28),
            self.changeCalendarMode.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        NSLayoutConstraint.activate([
            self.dDayLabel.bottomAnchor.constraint(equalTo: self.frameView.topAnchor, constant: -10),
            self.dDayLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        self.goalTimeView.snp.makeConstraints{ make in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.bottom.equalTo(self.barView.snp.top).offset(-6)
            make.trailing.equalTo(self.barView.snp.trailing)
        }
        
        //Level 2
        self.barView.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
            make.trailing.equalTo(self.frameView.snp.trailing).offset(-30)
        }
        
        self.titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        
        self.previousMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.titleView.snp.trailing)
            make.height.width.equalTo(28)
            make.centerY.equalTo(titleView.snp.centerY)
        }
        
        self.nextMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.previousMonthButton.snp.trailing).offset(4)
            make.height.width.equalTo(28)
            make.centerY.equalTo(titleView.snp.centerY)
        }
        
        self.calendarView.snp.makeConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom).offset(12)
            make.leading.equalTo(self.frameView.snp.leading).offset(10)
            make.trailing.equalTo(self.frameView.snp.trailing).offset(-10)
        }
        
        self.calendarViewHeight = self.calendarView.heightAnchor.constraint(equalToConstant: 66)
        self.calendarViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            self.toDoTableView.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor, constant: 10),
            self.toDoTableView.bottomAnchor.constraint(equalTo: self.goalTimeView.topAnchor),
            self.toDoTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.toDoTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        ])
        
        self.categoryEditButton.snp.makeConstraints{ make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(34)
        }
        
        NSLayoutConstraint.activate([
            self.categoryEditButton.leadingAnchor.constraint(equalTo: self.itemBoxView.leadingAnchor),
            self.categoryEditButton.widthAnchor.constraint(equalToConstant: 34),
            self.categoryEditButton.topAnchor.constraint(equalTo: self.itemBoxView.topAnchor),
            self.categoryEditButton.bottomAnchor.constraint(equalTo: self.itemBoxView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.chartViewButton.topAnchor.constraint(equalTo: self.itemBoxView.topAnchor),
            self.chartViewButton.bottomAnchor.constraint(equalTo: self.itemBoxView.bottomAnchor),
            self.chartViewButton.leadingAnchor.constraint(equalTo:  self.categoryEditButton.trailingAnchor, constant: 10),
            self.chartViewButton.widthAnchor.constraint(equalToConstant: 34),
        ])
        
        NSLayoutConstraint.activate([
            self.itemBoxView.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 20),
            self.itemBoxView.heightAnchor.constraint(equalToConstant: 34),
            self.itemBoxView.trailingAnchor.constraint(equalTo: self.barView.leadingAnchor, constant: -10),
            self.itemBoxView.centerYAnchor.constraint(equalTo: self.barView.centerYAnchor, constant: -4)
        ])
    }
    //MARK: AddTarget
    func addTarget(){
        self.chartViewButton.addTarget(self, action: #selector(self.clickToChartButton), for: .touchUpInside)
        self.previousMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.nextMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.categoryEditButton.addTarget(self, action: #selector(self.pushCategoryVC(_:)), for: .touchUpInside)
        self.changeCalendarMode.addTarget(self, action: #selector(self.changeCalendarMode(_:)), for: .touchUpInside)
    }
    
    //MARK: AddObserver
    func addObserverMtd(){
        let notificationCenter = NotificationCenter.default
        // 키보드 나오고 들어갈때 호출되는 메소드 추가!
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 근접센서가 작동할때 호출되는 메소드 추가 !
        notificationCenter.addObserver(self, selector: #selector(proximityChangedMtd(sender:)), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }
}


//MARK:- TabelView delegate datasource
extension StopWatchViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.realm.objects(Segments.self).count // 섹션 수 = 과목 수
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter?.dailySegment
        StopWatchDAO().checkSegmentData(date: self.saveDate)
        return segment?[section].toDoList.count ?? 0 // 오늘의 리스트가 없으면 0개
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let segment = self.realm.objects(Segments.self)
        
        let view = TodoListHeaderView()

        let colorCode = segment[section].colorCode
        let color = self.view.uiColorFromHexCode(colorCode)
        view.categoryNameLabel.text = segment[section].name
        view.frameView.backgroundColor = color

        view.categoryNameLabel.textColor = color.isDarkColor ? UIColor.systemGray4 : UIColor.white
        view.plusImageView.tintColor = color.isDarkColor ? UIColor.systemGray4 : UIColor.white
        
        view.touchViewButton.tag = section
        view.touchViewButton.addTarget(self, action: #selector(self.clickedSection(_:)), for: .touchUpInside)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoListCell
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter?.dailySegment
        
        cell.saveDate = self.saveDate
        cell.getListTextField.tag = indexPath.section // 섹션구분 태그 이용
        cell.contentView.tag = indexPath.section
        cell.changeImageButton.tag = indexPath.row
        cell.getListTextField.delegate = self
        cell.getListTextField.isHidden = true
        cell.getListTextField.text = ""
        cell.listLabel.text = ""
        cell.checkImageView.image = nil
        cell.checkImageView.isHidden = true

        let colorCode = self.realm.objects(Segments.self)[indexPath.section].colorCode
        let color = self.view.uiColorFromHexCode(colorCode)
        let text = segment?[indexPath.section].toDoList[indexPath.row]
        let checkImageIndex = segment?[indexPath.section].listCheckImageIndex[indexPath.row]
        let checkImage = CheckImage.init(rawValue: checkImageIndex ?? 0)
        if text == ""{
            cell.getListTextField.isHidden = false
            cell.getListTextField.underLine.backgroundColor = color
            cell.getListTextField.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [.foregroundColor: color])
        }else{
            cell.listLabel.text = text
            cell.lineView.backgroundColor = color
            cell.checkImageView.image = checkImage?.image
            cell.checkImageView.isHidden = false
            cell.getListTextField.isHidden = true
        }

        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.editTodoListView == nil else { return }
        
        self.editTodoListView = {
            let view = EditTodoListView()
            self.setTapGesture() // 외부 탭 하면 닫히는 제스쳐 추가
            self.view.addSubview(view)
            
            view.editButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            view.deleteButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            view.changeCheckImageButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            view.changeDateButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            
            let object = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
            let title = object?.dailySegment[indexPath.section].toDoList[indexPath.row] // list 불러오기
            view.title.text = "' \(title!) '"
            
            view.frame.size = CGSize(width: self.view.frame.width - 40, height: 100)
            view.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 45)
            UIView.animate(withDuration: 0.5){
                view.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 80)
            }
            view.indexPath = indexPath
            
            return view
        }()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let categoryCount = self.realm.objects(Segments.self).count
        
        let guideText = "카테고리를 눌러 할일을 추가해주세요."
        
        // 마지막 섹션에 문구 출력
        if section == (categoryCount - 1) {
           // 오늘의 데이터가 nil일때
            guard let category = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate) else { return guideText }
            
            var sum = 0 // todolist 합
            
            for seg in category.dailySegment{
                sum += seg.toDoList.count
            }
            // 합이 0 이면 안내문구
            if sum == 0 {
                return guideText
            }
        }
        
        return nil
    }
}

extension StopWatchViewController: UITextFieldDelegate {
    //입력이 끝나면 호출되는 델리게이트메소드
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment

        let row = segment[textField.tag].toDoList.count - 1
        
        if textField.text == "" {

            try! self.realm.write{
                segment[textField.tag].toDoList.remove(at: row)
                segment[textField.tag].listCheckImageIndex.remove(at: row)
            }
            StopWatchDAO().deleteSegment(date: self.saveDate)
            
        }else {

            try! self.realm.write{
                segment[textField.tag].toDoList[row] = textField.text!
            }
        }
        self.toDoTableView.reloadData()
        self.calendarView.calendarView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment

        let row = segment[textField.tag].toDoList.count - 1
        let indexPath = IndexPath(row: row, section: textField.tag)
        self.toDoTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

//MARK:- editListMethod
extension StopWatchViewController {
    
    @objc func editListMethod(_ sender: UIButton){
        if let editView = self.editTodoListView {
            let indexPath = editView.indexPath
            let (section,row) = (indexPath!.section,indexPath!.row)
            guard let segment = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.dailySegment else { return }
            let toDoList = segment[indexPath!.section].toDoList[editView.indexPath!.row] // 이전텍스트 불러오기
            
            if sender.tag == 0 { // 수정버튼이면
                let alert = UIAlertController(title: "무엇으로 변경할까요?", message: nil, preferredStyle: .alert)
                alert.addTextField(){
                    $0.text = toDoList
                }
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "확인", style: .default){ (_) in
                    
                    try! self.realm.write{
                        segment[section].toDoList[row] = (alert.textFields?[0].text)!
                    }
                    self.toDoTableView.reloadData()
                    self.closeListEditView()
                    
                })
                self.present(alert, animated: false)
            }

            if sender.tag == 1 { // 삭제 버튼이면
                let alert = UIAlertController(title: nil, message: "정말 삭제 하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "확인", style: .default){ (_) in
                    try! self.realm.write{
                        segment[section].toDoList.remove(at: row) // 리스트 삭제
                        segment[section].listCheckImageIndex.remove(at: row)
                    }
                    StopWatchDAO().deleteSegment(date: self.saveDate) // 데이터베이스에서 삭제
                    self.toDoTableView.reloadData()
                    self.calendarView.calendarView.reloadData()
                    self.closeListEditView()
                })

                self.present(alert, animated: false)
            }
            
            if sender.tag == 2 { //모양변경 버튼이면
                var index = segment[section].listCheckImageIndex[row]
                index += 1
                try! self.realm.write{
                    segment[section].listCheckImageIndex[row] = index % 4
                }
                
                self.toDoTableView.reloadData()
            }
            
            if sender.tag == 3 { // 날짜 변경 버튼
                let calendar: CalendarModalView = {
                    let calendar = CalendarModalView()
                    calendar.translatesAutoresizingMaskIntoConstraints = false
                    
                    calendar.calendarView.saveDate = self.saveDate
                    calendar.calendarView.presentDate = self.saveDate
                    calendar.changeDate = self.saveDate
                    calendar.saveDate = self.saveDate
                    
                    
                    self.view.addSubview(calendar)
                    NSLayoutConstraint.activate([
                        calendar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        calendar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                        calendar.topAnchor.constraint(equalTo: self.view.topAnchor),
                        calendar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                    ])
                    
                    
                    calendar.indexpath = indexPath!
                    
                    calendar.okButton.addTarget(self, action: #selector(self.clickOkButton(_:)), for: .touchUpInside)
                    calendar.postponeButton.addTarget(self, action: #selector(self.postponeList(sender:)), for: .touchUpInside)
                    
                    return calendar
                }()
                
                self.closeListEditView()
            }
            
        }
    }
    
    func closeListEditView(){
        if let editView = self.editTodoListView {
            UIView.animate(withDuration: 0.3,animations: {
                editView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 40)
            }){ (_) in
                editView.removeFromSuperview() // 슈퍼뷰에서 제거!
                self.editTodoListView = nil
                self.removeTapView()
            }
        }
    }
}

extension StopWatchViewController {
    //MARK: - ModalCalendarView Selector
    
    @objc func clickOkButton(_ sender: UIButton){
        let modalView = sender.superview?.superview as! CalendarModalView
        let _ = StopWatchDAO().create(date: modalView.saveDate)
        let section = modalView.indexpath.section
        let row = modalView.indexpath.row
        
        self.changeDate(modalView: modalView, section: section, row: row)
        
    }
    
    @objc func postponeList(sender: UIButton){
        let today = (UIApplication.shared.delegate as! AppDelegate).resetDate
        let modalView = sender.superview?.superview as! CalendarModalView
        let section = modalView.indexpath.section
        let row = modalView.indexpath.row
        var date = ""
        
        var (intYear,intMonth,intDay): (Int,Int,Int) = CalendarMethod().splitDate(date: today)
        let maxDay = CalendarMethod().getMonthDay(year: intYear, month: intMonth)
        
        if modalView.compareDate {
            if intDay == maxDay {
                let (year,month,_) = CalendarMethod().changeMonth(tag: 1, date: today)
                intYear = year
                intMonth = month
                intDay = 1
            }else {
                intDay += 1
            }
            date = String(intYear) + "." + self.view.returnString(intMonth) + "." + self.view.returnString(intDay)
        }else {
            date = today
        }
        
        modalView.saveDate = date
        modalView.calendarView.saveDate = date
        modalView.calendarView.presentDate = date
        modalView.calendarView.calendarView.reloadData()
        modalView.titleView.label.text = CalendarMethod().convertDate(date: date)
        
        let _ = StopWatchDAO().create(date: modalView.saveDate)
        
        self.changeDate(modalView: modalView, section: section, row: row)
    }
    
    func changeDate(modalView: CalendarModalView, section: Int, row: Int){
        let segment = realm.objects(SegmentData.self).where{ seg in
            seg.date == modalView.changeDate
        }[section]
        
        let text = segment.toDoList[row]
        let destination = realm.objects(SegmentData.self).where{ seg in
            seg.date == modalView.saveDate
        }[section]
        
        let alert = UIAlertController(title: nil, message: "선 택", preferredStyle: .alert)
        let move = UIAlertAction(title: "이동하기", style: .default){ _ in
            try! self.realm.write{
                segment.toDoList.remove(at: row)
                segment.listCheckImageIndex.remove(at: row)
                
                destination.toDoList.append(text)
                destination.listCheckImageIndex.append(0)
            }
            StopWatchDAO().deleteSegment(date: modalView.changeDate)
            modalView.removeFromSuperview()
            self.toDoTableView.reloadData()
            self.calendarView.calendarView.reloadData()
        }
        
        let copy = UIAlertAction(title: "복사하기", style: .default){ _ in
            try! self.realm.write{
                //복사
                destination.toDoList.append(text)
                destination.listCheckImageIndex.append(0)
            }
            StopWatchDAO().deleteSegment(date: modalView.changeDate)
            modalView.removeFromSuperview()
            self.toDoTableView.reloadData()
            self.calendarView.calendarView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(move)
        alert.addAction(copy)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
