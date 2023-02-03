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
    var todoList = List<SegmentData>()
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
        self.layout()
        self.addTarget()
        self.addObserver()
        
        self.toDoTableView.delegate = self
        self.toDoTableView.dataSource = self
        
        // gesture
        self.hideKeyboardWhenTapped()
//        print("path =  \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 프로퍼티 값 갱신
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).resetDate //오늘 날짜!
        
        self.setDeviceMotion()   // coremotion 시작
        self.reloadProgressBar() // 진행바 재로딩
        self.setNavigationBar()  // 네비게이션바 설정
        self.toDoTableView.reloadData()
        self.calendarView.calendarView.reloadData()
        self.setDday()
        self.setTimeLabel()
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
        let time = StopWatchDAO().getTotalTime(self.calendarView.selectDateComponent)
        let goal = StopWatchDAO().getTotalGoalTime(self.calendarView.selectDateComponent)
        self.barView.per = goal != 0 ? Float(time / goal) : 0
    }
    
    func setTimeLabel(){
        let time = StopWatchDAO().getTotalTime(self.calendarView.selectDateComponent)
        self.mainTimeLabel.updateTime(self.view.divideSecond(timeInterval: time))
    }
    
    func setGoalTime(){
        let goal = StopWatchDAO().getTotalGoalTime(self.calendarView.selectDateComponent)
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
                StopWatchDAO().deleteDailyData(date: self.saveDate)
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
        let section = sender.tag
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
    
    @objc func willPresentAlert(_ notification: Notification) {
        guard let alert = notification.userInfo?["alert"] as? UIAlertController else { return }
        self.present(alert, animated: true)
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
    
    // 타이머 구동 방식
    func setDeviceMotion(){
        // 메뉴 닫기
        self.delegate?.closeMenu()
        
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 0.1;
        self.motionManager?.startDeviceMotionUpdates(to: .main) {
            (motion, error) in
            
            guard let attitude = motion?.attitude else {
                print("motion error")
                return }
            
            let proximityState = UIDevice.current.proximityState //get proximity state!
            let degree = abs(attitude.roll * 180.0 / Double.pi) //get degree

            if degree >= 100{ // 100도 이상 기울어지면 근접 센서 가동
                UIDevice.current.isProximityMonitoringEnabled = true
                if degree >= 160 && proximityState == true { // 160도 이상 기울어지고 근접 센서가 true이면 타이머 시작
                    if self.concentraionTimerVC != nil { // 집중화면 인스턴스 존재시엔 타이머 재시작
                        self.concentraionTimerVC!.openBlackView()
                    }else{
                        self.concentraionTimerVC = ConcentrationTimeViewController() // 집중화면 인스턴스 없으면 타이머 최초시작
                        self.navigationController?.pushViewController(self.concentraionTimerVC!, animated: false)
                    }
                    
                    self.motionManager?.stopDeviceMotionUpdates() // 코어모션 업데이트 메소드 중단! ( 근접센서 false시 재 작동 )
                }
            } else if degree < 100 && proximityState == false { // 100도 이하고 근접 센스가 false면 근접센서 작동 중단 + 타이머 가동중이면 타이머도 중단
                UIDevice.current.isProximityMonitoringEnabled = false
                guard let timerVC = self.concentraionTimerVC else { return }
                timerVC.closeBlackView()
            }
        }
    }
    
    //MARK: - AddSubView
    private func addSubView(){
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
    
    //MARK: - Layout
    private func layout(){
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
    
    //MARK: - AddTarget
    private func addTarget(){
        self.chartViewButton.addTarget(self, action: #selector(self.didClickChartButton), for: .touchUpInside)
        self.categoryEditButton.addTarget(self, action: #selector(self.didClickMenu(_:)), for: .touchUpInside)
    }
    
    //MARK: - AddObserver
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
        let colorCode = segment[section].colorCode
        let color = self.view.uiColorFromHexCode(colorCode)
        
        let view = TodoListHeaderView().then {
            $0.categoryNameLabel.text = segment[section].name
            $0.frameStackView.backgroundColor = color
            $0.categoryNameLabel.textColor = color.isDarkColor ? UIColor.systemGray4 : UIColor.white
            $0.plusImageView.tintColor = color.isDarkColor ? UIColor.systemGray4 : UIColor.white
            $0.touchViewButton.tag = section
            $0.touchViewButton.addTarget(self, action: #selector(self.didClickSection(_:)), for: .touchUpInside)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoListCell
        let segData = StopWatchDAO().getSegmentData(self.calendarView.selectDateComponent.stringFormat, section: indexPath.section)
        
        cell.saveDateComponents = self.calendarView.selectDateComponent
        cell.getListTextField.tag = indexPath.section // 섹션구분 태그 이용
        cell.indexPath = indexPath
        cell.getListTextField.delegate = self
        
        let text = segData.toDoList[indexPath.row]
        
        if text == "" {
            cell.configureCellWhenAddingTodoList()
        } else {
            cell.configureCell(segData)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.editTodoListView == nil else { return }
        
        self.editTodoListView = EditTodoListView(indexPath).then {
            self.view.addSubview($0)
            self.hideSubviewWhenTapped()
        
            let segData = StopWatchDAO().getSegmentData(self.calendarView.selectDateComponent.stringFormat, section: indexPath.section)
            let title = segData.toDoList[indexPath.row] // list 불러오기
            
            $0.title.text = "' \(title) '"
            
            $0.buttonStackView.subviews.forEach {
                ($0 as? ListEditItemView)?.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            }
            
            $0.frame.size = CGSize(width: self.view.frame.width - 40, height: 100)
            $0.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 45)
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
            StopWatchDAO().deleteDailyData(date: self.saveDate)
            
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
        guard let editView = self.editTodoListView else { return }
        let segData = StopWatchDAO().getSegmentData(self.calendarView.selectDateComponent.stringFormat, section: editView.section)
        let toDoList = segData.toDoList[editView.row] // 이전텍스트 불러오기
        
        switch sender.tag {
        case 0:
            let alert = UIAlertController(title: "무엇으로 변경할까요?", message: nil, preferredStyle: .alert)
            alert.addTextField() { $0.text = toDoList }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                StopWatchDAO().editTodoList(segData, row: editView.row, text: (alert.textFields?[0].text)!)
                self.toDoTableView.reloadData()
                self.closeListEditView()
            })
            
            self.present(alert, animated: true)
        case 1:
            self.defaultAlert(title: nil, message: "정말 삭제 하시겠습니까?") {
                StopWatchDAO().deleteTodoList(segData, row: editView.row)
                StopWatchDAO().deleteDailyData(date: self.calendarView.selectDateComponent.stringFormat) // 데이터베이스에서 삭제
                self.calendarView.calendarView.reloadData()
                self.toDoTableView.reloadData()
            }
            
            self.closeListEditView()
        case 2:
            StopWatchDAO().changeListCheckImage(segData, row: editView.row)
            self.toDoTableView.reloadData()
        case 3:
            _ = CalendarModalView(self.calendarView.selectDateComponent).then {
                $0.indexPath = IndexPath(row: editView.row, section: editView.section)
                
                self.view.addSubview($0)
                $0.snp.makeConstraints { make in
                    make.leading.top.bottom.trailing.equalToSuperview()
                }
            }
            self.closeListEditView()
        default:
            print("This button tag does not exist.")
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
