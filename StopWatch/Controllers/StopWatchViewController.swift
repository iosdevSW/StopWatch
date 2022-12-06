//
//  StopWatchViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/29.
//

// 1. 달 -> 영어로 바꾸는거 enum 모델링하기
// 2. ModalCalendarView 뜯어고치기
// 3. 저장될때 세이브데이트 바꿔주기

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
    private var motionManager: CMMotionManager?
    
    var concentraionTimerVC: ConcentrationTimeViewController?
    var editTodoListView: EditTodoListView?
    var editGoalTimeView: EditGoalTimeView?
    var chartView: ChartView?
    var tapGesture: UITapGestureRecognizer?
    
    weak var delegate: StopWatchVCDelegate?
    
    var saveDate: String = ""
    
    private let guideLabelView = GuideLabelView()
    private let calendarView = CalendarView()
    private let goalTimeView = GoalTimeView()
    private let itemBoxView = UIView()
    private let barView = DrawBarView()
    
    let frameView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 50
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let mainTimeLabel = TimeLabel(.hms).then {
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 50, weight: .regular)
    }
    
    private let chartViewButton = UIButton(type: .system).then {
        $0.backgroundColor = .systemGray6
        $0.setImage(UIImage(systemName: "chart.pie.fill"), for: .normal)
        $0.tintColor = .darkGray
        $0.layer.cornerRadius = 10
    }
    
    private let dDayLabel = UILabel().then {
        $0.font = UIFont(name: "Times New Roman", size: 16)
        $0.textColor = .darkGray
        $0.text = "-days left"
    }
    
    private let toDoTableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(TodoListCell.self, forCellReuseIdentifier: "cell")
        $0.separatorStyle = .none
        $0.bounces = false
        $0.showsVerticalScrollIndicator = false
        if #available(iOS 15, *) {
            $0.sectionHeaderTopPadding = 0
        }
    }
    
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
        self.configured()
        self.addSubView()
        self.layOut()
        self.addTarget()
        self.addObserver()
        
        self.toDoTableView.delegate = self
        self.toDoTableView.dataSource = self
        
        // gesture
        self.hideKeyboardWhenTapped()
        
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
        self.guideLabelView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.autoScrollCurrentDate()
        if self.calendarView.calendarMode == .week {
            self.guideLabelView.startAnimate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.motionManager?.stopDeviceMotionUpdates()
        self.guideLabelView.stopAnimate()
    }
    
    //MARK: - Method
    private func autoScrollCurrentDate(){ // 현재 날짜로 달력 스크롤
        let itemIndex = CalendarMethod().returnIndexOfDay(date: self.saveDate)
        self.calendarView.calendarView.scrollToItem(at: IndexPath(item: itemIndex - 1, section: 0), at: .left, animated: true)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationItem.backButtonTitle = ""
    }
    
    private func reloadProgressBar(){
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
    
    //목표 시간 설정 뷰 열기
    func openGoalTimeEditView() {
        guard self.editGoalTimeView == nil else { return } // 이미 객체가 생성되었으면 더 못생성되게 막기
        
        self.editGoalTimeView = EditGoalTimeView().then {
            self.view.addSubview($0)
            
            self.hideSubviewWhenTapped()
            $0.cancelButton.addTarget(self, action: #selector(self.didFinishEditingGoalTime(_:)), for: .touchUpInside)
            $0.okButton.addTarget(self, action: #selector(self.didFinishEditingGoalTime(_:)), for: .touchUpInside)
            
            $0.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(30)
                make.trailing.equalToSuperview().offset(-30)
                make.bottom.equalToSuperview().offset(-20)
                make.height.equalTo(200)
            }
        }
        
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
    
    //목표 시간 설정 뷰 닫기
    func closeGoalTimeEditView() {
        if let _editGoalTimeView = self.editGoalTimeView {
            UIView.animate(withDuration: 0.5,animations: {
                _editGoalTimeView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }){_ in
                StopWatchDAO().deleteSegment(date: self.saveDate)
                _editGoalTimeView.removeFromSuperview()
                self.editGoalTimeView = nil
                self.removeTapGesture()
            }
        }
    }
    
    //MARK: - gestrue method
    private func setSwipeGesture(){
        //차트뷰 아래로 내려서 닫기 제스쳐 추가
        if let view = self.chartView {
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
            downSwipe.direction = .down
            view.addGestureRecognizer(downSwipe)
        }
    }
    
    // 서브뷰가 떠있을때 외부 뷰 탭
    private func hideSubviewWhenTapped() {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture!)
    }
    
    private func removeTapGesture() {
        guard let tapGesture else { return }
        self.view.removeGestureRecognizer(tapGesture)
        self.tapGesture = nil
    }
    
    // 차트뷰 열기
    func openChartView(){
        if self.chartView != nil { return }
        
        self.chartView = ChartView().then {
            $0.saveDate = self.saveDate
            
            self.frameView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.calendarView.snp.bottom)
                make.leading.trailing.bottom.equalTo(self.frameView)
            }
        }
        
        self.setSwipeGesture()
        self.chartView!.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        UIView.animate(withDuration: 0.5){
            self.chartView!.transform = .identity
        }
    }
    
    // 차트 뷰 닫는 함수
    private func closeChartView(){
        if let modal = self.chartView {
            UIView.animate(withDuration: 0.5 ,animations: {
                modal.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }) {_ in
                modal.removeFromSuperview()
                self.chartView = nil
            }
        }
    }
    
    private func setDday(){
        let day = UserDefaults.standard.value(forKey: "dday") as? Date ?? Date()
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
    
    func openCategoryVC() {
        let categoryVC = CategoryViewController()
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //MARK: CalendarView method
    func clickDay(saveDate: String) {
        self.saveDate = saveDate
        self.chartView?.saveDate = saveDate
        self.chartView?.setNeedsDisplay() // 차트 다시 그리기
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
    
    //탭 제스쳐를 감지하여 뷰를 닫는 액션함수
    @objc func respondToTapGesture(_ sender: Any){
        self.closeListEditView()        //편집 뷰가 열려 있으면 편집 뷰 닫기
        self.closeGoalTimeEditView()    //골타임설정 뷰가 열려 있으면 닫기
    }

    //주 <-> 월 달력 변경 버튼 클릭
    @objc func didClickChangeCalendarMode(_ sender: UIButton){
        UIView.animate(withDuration: 0.5) {
            switch self.calendarView.calendarMode {
            case .week:
                self.calendarView.calendarMode = .month
                
                self.calendarView.snp.updateConstraints{ make in
                    make.height.equalTo(268)
                }
                self.calendarView.superview?.layoutIfNeeded()
                
                self.frameView.snp.remakeConstraints { make in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.height.equalToSuperview().multipliedBy(0.86)
                }
                self.frameView.superview?.layoutIfNeeded()
                self.mainTimeLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.dDayLabel.alpha = 0
                self.calendarView.changeCalendarMode.setTitle("월▾", for: .normal)
                self.mainTimeLabel.layoutIfNeeded()
                self.chartView?.updateConstant(0)
            case .month:
                self.calendarView.calendarMode = .week
                
                self.calendarView.snp.updateConstraints { make in
                    make.height.equalTo(114)
                }
                self.calendarView.superview?.layoutIfNeeded()
                
                self.frameView.snp.remakeConstraints { make in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.height.equalToSuperview().multipliedBy(0.76)
                }
                self.frameView.superview?.layoutIfNeeded()
                
                self.mainTimeLabel.font = .systemFont(ofSize: 50, weight: .regular)
                self.mainTimeLabel.transform = .identity
                self.dDayLabel.alpha = 1
                self.calendarView.changeCalendarMode.setTitle("주▾", for: .normal)
                self.mainTimeLabel.layoutIfNeeded()
        
                self.chartView?.updateConstant(30)
                self.guideLabelView.stopAnimate() // 가이드 레이블 멈춤
            }
            self.chartView?.setNeedsDisplay() // 차트 뷰 다시그리기
        }
    }
    
    @objc func didChangeSaveDate(_ notification: Notification) {
        if let saveDate = notification.userInfo?["selectedDate"] as? String {
            self.saveDate = saveDate
        }
        self.setGoalTime() // 목표시간 Label 재설정
        self.reloadProgressBar() // 진행바 재로딩
        self.setTimeLabel() // 현재시간 Label 재설정
        self.toDoTableView.reloadData()
        self.calendarView.calendarView.reloadData()
        self.chartView?.saveDate = self.saveDate
        self.chartView?.setNeedsDisplay() // 차트 다시 그리기
    }
    
    @objc func proximityChangedMtd(sender: Notification){
        let isTrue = UIDevice.current.isProximityMonitoringEnabled
        if UIDevice.current.proximityState && isTrue {
        } else {
            self.setDeviceMotion()
        }
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
    
    @objc func didClickChartButton(){
        if self.chartView == nil {
            self.openChartView()
        }else {
            self.closeChartView()
        }
    }
    
    @objc func didClickMenu(_ button: UIBarButtonItem){
        self.delegate?.handleMenuToggle(menuOption: nil)
    }
    
    //세션(과목명)을 눌렀을때 호출되는 메소드
    @objc func didClickSection(_ sender: UIButton){
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
            print("미구현")
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
        self.view.addSubview(self.guideLabelView)
    
        self.frameView.addSubview(self.calendarView)
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
            make.height.equalToSuperview().multipliedBy(0.76)
        }
        
        self.dDayLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.frameView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        self.goalTimeView.snp.makeConstraints{ make in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.bottom.equalTo(self.barView.snp.top).offset(-6)
            make.trailing.equalTo(self.barView.snp.trailing)
        }
        
        self.guideLabelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(30)
        }
        
        //Level 2
        self.barView.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
            make.trailing.equalTo(self.frameView.snp.trailing).offset(-30)
        }

        self.calendarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(self.frameView.snp.leading).offset(10)
            make.trailing.equalTo(self.frameView.snp.trailing).offset(-10)
            make.height.equalTo(114)
        }
        
        self.itemBoxView.snp.makeConstraints{ make in
            make.leading.equalTo(self.frameView.snp.leading).offset(20)
            make.trailing.equalTo(self.barView.snp.leading).offset(-10)
            make.height.equalTo(34)
            make.centerY.equalTo(self.barView.snp.centerY)
        }
        
        self.toDoTableView.snp.makeConstraints { make in
            make.top.equalTo(self.calendarView.snp.bottom).offset(10)
            make.bottom.equalTo(self.goalTimeView.snp.top)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    
        self.categoryEditButton.snp.makeConstraints{ make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(34)
        }
        
        self.chartViewButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(self.categoryEditButton.snp.trailing).offset(10)
            make.width.equalTo(34)
        }
    }
    
    //MARK: AddTarget
    private func addTarget(){
        self.chartViewButton.addTarget(self, action: #selector(self.didClickChartButton), for: .touchUpInside)
        self.categoryEditButton.addTarget(self, action: #selector(self.didClickMenu(_:)), for: .touchUpInside)
    }
    
    //MARK: AddObserver
    private func addObserver() {
        let notificationCenter = NotificationCenter.default
        // 키보드 나오고 들어갈때 호출되는 메소드 추가!
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 근접센서가 작동할때 호출되는 메소드 추가 !
        notificationCenter.addObserver(self, selector: #selector(self.proximityChangedMtd(sender:)), name: UIDevice.proximityStateDidChangeNotification, object: nil)
        //주 <-> 월 달력이 바뀔때
        notificationCenter.addObserver(self, selector: #selector(self.didClickChangeCalendarMode(_:)), name: .changeCalendarMode, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.willPresentAlert(_:)), name: .presentAlert, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.didChangeSaveDate(_:)), name: .changeSaveDate, object: nil)
    }
}

//MARK: - TabelView delegate datasource
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
        view.touchViewButton.addTarget(self, action: #selector(self.didClickSection(_:)), for: .touchUpInside)
        
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
        
        self.editTodoListView = EditTodoListView().then {
            self.view.addSubview($0)
            self.hideSubviewWhenTapped()
            
            $0.editButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            $0.deleteButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            $0.changeCheckImageButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            $0.changeDateButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            
            let object = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
            let title = object?.dailySegment[indexPath.section].toDoList[indexPath.row] // list 불러오기
            $0.title.text = "' \(title!) '"
            
            $0.frame.size = CGSize(width: self.view.frame.width - 40, height: 100)
            $0.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 45)
            $0.indexPath = indexPath
        }
        UIView.animate(withDuration: 0.5) {
            self.editTodoListView?.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 80)
        }
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

//MARK: - editListMethod
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
                self.defaultAlert(title: nil, message: "정말 삭제 하시겠습니까?") {
                    try! self.realm.write{
                        segment[section].toDoList.remove(at: row) // 리스트 삭제
                        segment[section].listCheckImageIndex.remove(at: row)
                    }
                    StopWatchDAO().deleteSegment(date: self.saveDate) // 데이터베이스에서 삭제
                    self.toDoTableView.reloadData()
                    self.calendarView.calendarView.reloadData()
                    self.closeListEditView()
                }
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
                _ = CalendarModalView(self.calendarView.selectDateComponent).then {
                    $0.indexPath = indexPath!
                    
                    self.view.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.leading.top.bottom.trailing.equalToSuperview()
                    }
                }
                
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
                self.removeTapGesture()
            }
        }
    }
}

extension StopWatchViewController {
    //MARK: - ModalCalendarView Selector
    @objc func willPresentAlert(_ notification: Notification) {
        guard let alert = notification.userInfo?["alert"] as? UIAlertController else { return }
        self.present(alert, animated: true)
    }
}
