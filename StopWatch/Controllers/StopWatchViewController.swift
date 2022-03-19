//
//  StopWatchViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/29.
//

import UIKit
import CoreMotion
import RealmSwift

class StopWatchViewController: UIViewController {
    //MARK: - Properties
    let realm = try! Realm()
    var saveDate: String = "" {
        didSet{ // 날짜가 바뀔 때마다
            self.setGoalTime() // 목표시간 Label 재설정
            self.reloadProgressBar() // 진행바 재로딩
            self.setTimeLabel() // 현재시간 Label 재설정
            self.titleView.label.text = CalendarMethod().convertDate(date: self.saveDate) // 타이틀 날짜 다시표시
            self.toDoTableView.reloadData()
            self.calendarView.day = Int(CalendarMethod().splitDate(date: self.saveDate).2) ?? 0
            self.calendarView.month = Int(CalendarMethod().splitDate(date: self.saveDate).1) ?? 0
            self.calendarView.year = Int(CalendarMethod().splitDate(date: self.saveDate).0) ?? 0
            self.calendarView.calendarView.reloadData()
        }
    }
    
    var totalTime: TimeInterval = 0
    var totalGoalTime: TimeInterval = 0
    var motionManager: CMMotionManager?
    var concentraionTimerVC: ConcentrationTimeViewController?
    var editListView: EditTodoListView?
    var editGoalTimeView: EditGoalTimeView?
    var chartView: ChartView?
    var tapGesture: UITapGestureRecognizer?
    var tapView: UIView?
    var delegate: StopWatchVCDelegate?
    var saveDateDelegate: SaveDateDetectionDelegate?
    
    let titleView: TitleView = {
        let view = TitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var calendarView: CalendarView = {
        let view = CalendarView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("<", for: .normal)
        button.tag = 0
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    let nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(">", for: .normal)
        button.tag = 1
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        
        return button
    }()

    let goalTimeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    lazy var goalTimeTitle: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.image = UIImage(systemName: "flag.fill")
        view.tintColor = .darkGray
        self.goalTimeView.addSubview(view)

        return view
    }()

    lazy var goalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = " 00 : 00"
        label.textColor = .darkGray
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .light)
        self.goalTimeView.addSubview(label)

        return label
    }()
    
    let frameView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 50
        
        return view
    }()
    
    let barView: DrawBarView = {
        let view = DrawBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let itemBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let mainTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00 : 00 : 00"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 50, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .standardColor
        label.textAlignment = .left
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let subTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
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
    
    let categoryEditButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = .darkGray
        button.tag = 2
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    let pickerView: UIDatePicker = {
        let view = UIDatePicker()
        
        return view
    }()
    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configured()   // 뷰 초기 설정 메소드
        self.addSubView()   // 서브뷰 추가 메소드
        self.layOut()       // 레이이웃 메소드
        self.addTarget()
        self.toDoTableView.delegate = self
        self.toDoTableView.dataSource = self
        self.hideKeyboardWhenTapped() //
        self.setNavigationItem()
        self.addObserverMtd() // 옵저버 추가
        self.reloadProgressBar()
//        print("path =  \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 프로퍼티 값 갱신
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate //오늘 날짜!
        self.totalTime = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.totalTime ?? 0
        self.totalGoalTime = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.totalGoalTime ?? 0
        
        self.setDeviceMotion()   // coremotion 시작
        self.reloadProgressBar() // 진행바 재로딩
        self.setNavigationBar()  // 네비게이션바 설정
        self.setDday()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.calendarView.calendarView.scrollToItem(at: NSIndexPath(item: 12, section: 0) as IndexPath, at: .left, animated: true)
    }
    
    func setNavigationBar() {
        // Set navigationbar Color ( ios15 기준 버전별로 분기 )
//        if #available(iOS 15.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()    // 불투명하게
//            appearance.backgroundColor = .standardColor
//            self.navigationController?.navigationBar.standardAppearance = appearance
//            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance    // 동일하게 만들기
//        }else {
//            self.navigationController?.navigationBar.barTintColor = .standardColor
//        }
        // 네비게이션바 숨기기
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .darkGray
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
//        self.navigationController?.navigationBar.clipsToBounds = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.motionManager?.stopDeviceMotionUpdates()
    }
    
    func reloadProgressBar(){
        let object = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        self.totalGoalTime = object?.totalGoalTime ?? 0
        self.barView.per =
            self.totalGoalTime != 0 ? Float(self.totalTime / self.totalGoalTime): 0
        self.barView.progressView.setProgress(self.barView.per, animated: true)
        self.barView.showPersent()
        
    }
    
    func setTimeLabel(){
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let time = dailyData?.totalTime ?? 0 // 오늘의 데이터가 없으면 0
        let (_,second,minute,hour) = self.view.divideSecond(timeInterval: time)
//        self.subTimeLabel.text = subSecond
        self.mainTimeLabel.text = "\(hour) : \(minute) :  \(second)"
    }
    
    func setGoalTime(){
        let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let goal = dailyData?.totalGoalTime ?? 0 // 오늘의 데이터가 없으면 0
        let (_,_,minute,hour) = self.view.divideSecond(timeInterval: goal)
        self.goalTimeLabel.text = " \(hour) : \(minute)"
    }
    
    // gestrue method
    func setSwipeGesture(){
        //차트뷰 아래로 내려서 닫기 제스쳐 추가
        if let view = self.chartView {
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
            downSwipe.direction = .down
            view.addGestureRecognizer(downSwipe)
        }
    }
    
    func setTapGesture(){
        if self.tapView == nil {
            self.tapView = UIView()
        }
        if let _tapView = self.tapView {
            _tapView.frame  = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(_tapView)
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture(_:)))
            
            _tapView.addGestureRecognizer(self.tapGesture!)
        }
    }
    
    func zeroTimeAlert(){
        let alert = UIAlertController(title: "알 림", message: "측정된 시간이 없습니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // subview open method
    func openChartView(){
        // DB불러오기 및 데이터 유무 확인
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        guard let segment = filter?.dailySegment else {
            self.zeroTimeAlert()
            return
        }
        
        // 총 시간 구하기
        let total = segment.reduce(0){
            (result,segment) in
            return segment.value + result
        }
        
        // 총 시간이 0 이면 경고 알림창띄우기.
        if total == 0 {
            self.zeroTimeAlert()
            return
        }
        
        // 차트뷰 중복생성 방지
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
        UIView.animate(withDuration: 0.3){
            self.chartView!.transform = .identity
        }
    }
    
    // 차트 뷰 닫는 함수
    func closeChartView(){
        if let modal = self.chartView {
            UIView.animate(withDuration: 0.3 ,animations: {
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
        self.dDayLabel.text = "\(dday) days left"
    }
    
    //SetNavigationItem
    func setNavigationItem() {
     
    }
    
    //MARK: Selector
    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer){
        switch gesture.direction {
        case .down:
            self.closeChartView()
        default:
            break
        }
    }
    
    @objc func respondToButton(_ button:UIButton){
        let (year,month,day) = CalendarMethod().changeMonth(tag: button.tag, date: self.saveDate)
        
        self.saveDate = String(year) + "." + self.view.returnString(month) + "." + self.view.returnString(day)
        
        // 바뀐 값 캘린더뷰로 전달하고 컬렉션뷰 리로드
        self.calendarView.day = day
        self.calendarView.month = month
        self.calendarView.year = year
        self.calendarView.calendarView.reloadData()
        
        self.saveDateDelegate?.detectSaveDate(date: self.saveDate)
    }

    
    @objc func proximityChangedMtd(sender: Notification){
        let isTrue = UIDevice.current.isProximityMonitoringEnabled
        if UIDevice.current.proximityState && isTrue {
        }else{
            self.setDeviceMotion()
        }
    }
    
    //목표 시간 설정 뷰 열기
    func openGoalTimeEditVC() {
        guard self.editGoalTimeView == nil else { return } // 이미 객체가 생성되었으면 더 못생성되게 막기
        self.editGoalTimeView = {
            let view = EditGoalTimeView()
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
            
            UIView.animate(withDuration: 0.5,animations: {
                self.editGoalTimeView!.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }){_ in
                StopWatchDAO().deleteSegment(date: self.saveDate)
                self.editGoalTimeView!.removeFromSuperview()
                self.editGoalTimeView = nil
            }
           
        }
        //취소버튼
        if sender.tag == 2 {
            UIView.animate(withDuration: 0.5, animations: {
                self.editGoalTimeView!.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            }){_ in
                StopWatchDAO().deleteSegment(date: self.saveDate)
                self.editGoalTimeView!.removeFromSuperview()
                self.editGoalTimeView = nil
            }
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
        self.view.bounds.origin = CGPoint(x: 0, y: keyboardHeight - (goalTimeView.frame.height)*2 - barView.frame.height + 4)
        
    }
    
    @objc func keyboardWillHide() {
        self.view.bounds.origin = .zero
    }
    
    func openCategoryVC() {
        let categoryVC = CategoryViewController()
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //탭 제스쳐를 감지하여 뷰를 닫는 액션함수
    @objc func respondToTapGesture(_ sender: Any){
        guard let _tapGesture = self.tapGesture else { return } // nil이면 그냥 종료
        //편집 뷰가 열려 있으면 편집 뷰 닫기
        self.closeListEditView()
        
        // 탭 제스쳐 제거
        self.tapGesture = nil
        self.view.removeGestureRecognizer(_tapGesture)
        // 탭뷰 제거
        self.tapView?.removeFromSuperview()
        self.tapView = nil
    }
    
    //MARK: CalendarView method
    
    func clickDay(saveDate: String) {
        self.saveDate = saveDate
        self.toDoTableView.reloadData()
    }
    
    //MARK: - SideBarMenu Method
    // 메뉴 터치에 따라 반응하는 함수
    func didSelectedMenuOption(menuOption: MenuOption){
        switch menuOption {
        case .category:
            let categoryVC = CategoryViewController()
            self.navigationController?.pushViewController(categoryVC, animated: true)
        case .goalTime:
            self.openGoalTimeEditVC()
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
        self.view.addSubview(self.mainTimeLabel)
        self.view.addSubview(self.dDayLabel)
        
        self.frameView.addSubview(self.titleView)
        self.frameView.addSubview(self.calendarView)
        self.frameView.addSubview(self.previousMonthButton)
        self.frameView.addSubview(self.nextMonthButton)
        self.frameView.addSubview(self.barView)
        self.frameView.addSubview(self.toDoTableView)
        self.frameView.addSubview(self.goalTimeView)
        self.frameView.addSubview(self.itemBoxView)
        
        self.itemBoxView.addSubview(self.chartViewButton)
        self.itemBoxView.addSubview(self.categoryEditButton)
        
//        self.mainTimeLabel.addSubview(self.subTimeLabel)
    }
    
    //MARK: SetLayOut
    func layOut(){
        //Level 1
        NSLayoutConstraint.activate([
            self.mainTimeLabel.bottomAnchor.constraint(equalTo: self.frameView.topAnchor),
            self.mainTimeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mainTimeLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.mainTimeLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.frameView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            self.frameView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.frameView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.frameView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.dDayLabel.bottomAnchor.constraint(equalTo: self.frameView.topAnchor, constant: -10),
            self.dDayLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.goalTimeView.widthAnchor.constraint(equalToConstant: 80),
            self.goalTimeView.heightAnchor.constraint(equalToConstant: 30),
            self.goalTimeView.bottomAnchor.constraint(equalTo: self.barView.topAnchor, constant: 0),
            self.goalTimeView.trailingAnchor.constraint(equalTo: self.barView.trailingAnchor, constant: -4),

            self.goalTimeLabel.topAnchor.constraint(equalTo: self.goalTimeView.topAnchor),
            self.goalTimeLabel.bottomAnchor.constraint(equalTo: self.goalTimeView.bottomAnchor),
            self.goalTimeLabel.trailingAnchor.constraint(equalTo: self.goalTimeView.trailingAnchor, constant: 6),
            self.goalTimeLabel.leadingAnchor.constraint(equalTo: self.goalTimeTitle.trailingAnchor),

            self.goalTimeTitle.centerYAnchor.constraint(equalTo: self.goalTimeView.centerYAnchor),
            self.goalTimeTitle.leadingAnchor.constraint(equalTo: self.goalTimeView.leadingAnchor),
            self.goalTimeTitle.widthAnchor.constraint(equalToConstant: 16),
            self.goalTimeTitle.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        //Level 2
        NSLayoutConstraint.activate([
            self.titleView.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 20),
            self.titleView.topAnchor.constraint(equalTo: self.frameView.topAnchor, constant: 30),
            self.titleView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            self.previousMonthButton.leadingAnchor.constraint(equalTo: self.titleView.trailingAnchor),
            self.previousMonthButton.heightAnchor.constraint(equalToConstant: 24),
            self.previousMonthButton.widthAnchor.constraint(equalToConstant: 24),
            self.previousMonthButton.centerYAnchor.constraint(equalTo: self.titleView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.nextMonthButton.leadingAnchor.constraint(equalTo: self.previousMonthButton.trailingAnchor, constant: 4),
            self.nextMonthButton.widthAnchor.constraint(equalToConstant: 24),
            self.nextMonthButton.heightAnchor.constraint(equalToConstant: 24),
            self.nextMonthButton.centerYAnchor.constraint(equalTo: self.titleView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.calendarView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: 16),
            self.calendarView.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 10),
            self.calendarView.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -10),
            self.calendarView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            self.toDoTableView.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor, constant: 20),
            self.toDoTableView.bottomAnchor.constraint(equalTo: self.goalTimeView.topAnchor),
            self.toDoTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.toDoTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.barView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            self.barView.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -30),
            self.barView.heightAnchor.constraint(equalToConstant: 40),
            self.barView.widthAnchor.constraint(equalToConstant: 240),
        ])
        
        NSLayoutConstraint.activate([
            self.categoryEditButton.leadingAnchor.constraint(equalTo: self.itemBoxView.leadingAnchor),
            self.categoryEditButton.widthAnchor.constraint(equalToConstant: 30),
            self.categoryEditButton.topAnchor.constraint(equalTo: self.itemBoxView.topAnchor),
            self.categoryEditButton.bottomAnchor.constraint(equalTo: self.itemBoxView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.chartViewButton.topAnchor.constraint(equalTo: self.itemBoxView.topAnchor),
            self.chartViewButton.bottomAnchor.constraint(equalTo: self.itemBoxView.bottomAnchor),
            self.chartViewButton.leadingAnchor.constraint(equalTo:  self.categoryEditButton.trailingAnchor, constant: 10),
            self.chartViewButton.widthAnchor.constraint(equalToConstant: 30),
        ])
        
        NSLayoutConstraint.activate([
            self.itemBoxView.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 20),
            self.itemBoxView.heightAnchor.constraint(equalToConstant: 30),
            self.itemBoxView.trailingAnchor.constraint(equalTo: self.barView.leadingAnchor, constant: -10),
            self.itemBoxView.centerYAnchor.constraint(equalTo: self.barView.centerYAnchor, constant: -4)
        ])
        
//        NSLayoutConstraint.activate([
//            self.subTimeLabel.centerYAnchor.constraint(equalTo: self.mainTimeLabel.centerYAnchor, constant: 3),
//            self.subTimeLabel.leadingAnchor.constraint(equalTo: self.mainTimeLabel.centerXAnchor, constant: 135)
//        ])
        
        //Level 3
       
    }
    //MARK: AddTarget
    func addTarget(){
        self.chartViewButton.addTarget(self, action: #selector(self.clickToChartButton), for: .touchUpInside)
        self.previousMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.nextMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.categoryEditButton.addTarget(self, action: #selector(self.pushCategoryVC(_:)), for: .touchUpInside)
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
        return segment?[section].toDoList.count ?? 0 // 오늘의 리스트가 없으면 0개
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let segment = self.realm.objects(Segments.self)
        
        let view = TodoListHeaderView()

        let colorCode = segment[section].colorCode
        let color = self.uiColorFromHexCode(colorCode)
        view.categoryNameLabel.text = segment[section].name
        view.frameView.backgroundColor = color
    
        view.touchViewButton.tag = section
        view.touchViewButton.addTarget(self, action: #selector(self.clickedSection(_:)), for: .touchUpInside)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoListCell
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment
        
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
        let color = self.uiColorFromHexCode(colorCode)
        let text = segment[indexPath.section].toDoList[indexPath.row]
        let checkImageIndex = segment[indexPath.section].listCheckImageIndex[indexPath.row]
        
        if text == ""{
            cell.getListTextField.isHidden = false
            cell.getListTextField.underLine.backgroundColor = color
            cell.getListTextField.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [.foregroundColor: color])
        }else{
            cell.listLabel.text = text
            cell.lineView.backgroundColor = color
            cell.checkImageView.image = checkImage().images[checkImageIndex]
            cell.checkImageView.isHidden = false
            cell.getListTextField.isHidden = true
        }

        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.editListView == nil else { return }
        
        self.editListView = EditTodoListView()
        if let _editListView = editListView {// 편집창 열기
            self.setTapGesture() // 외부 탭 하면 닫히는 제스쳐 추가
            self.view.addSubview(_editListView)
            // 각 버튼 액션메소드 추가
            _editListView.editButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            _editListView.deleteButton.button.addTarget(self, action: #selector(self.editListMethod(_:)), for: .touchUpInside)
            let object = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
            let title = object?.dailySegment[indexPath.section].toDoList[indexPath.row] // list 불러오기
            
            _editListView.title.text = "' \(title!) '"
            _editListView.frame.size = CGSize(width: self.view.frame.width - 40, height: 90)
            _editListView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 45)
            UIView.animate(withDuration: 0.5){
                _editListView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 70)
            }
            _editListView.indexPath = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
        if let editView = self.editListView {
            let indexPath = editView.indexPath
            let segment = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)?.dailySegment
            let toDoList = segment?[indexPath!.section].toDoList[editView.indexPath!.row] // 이전텍스트 불러오기
            
            if sender.tag == 0 { // 수정버튼이면
                let alert = UIAlertController(title: "무엇으로 변경할까요?", message: nil, preferredStyle: .alert)
                alert.addTextField(){
                    $0.text = toDoList
                }
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "확인", style: .default){ (_) in
                    
                    try! self.realm.write{
                        segment?[indexPath!.section].toDoList[editView.indexPath!.row] = (alert.textFields?[0].text)!
                    }
                    self.toDoTableView.reloadData()
                    self.closeListEditView()
                    
                })
                self.present(alert, animated: false)
            }

            if sender.tag == 1 { // 삭제 버튼이면
                let alert = UIAlertController(title: nil, message: "정말 삭제 하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "확안", style: .default){ (_) in
                    try! self.realm.write{
                        segment?[indexPath!.section].toDoList.remove(at: indexPath!.row) // 리스트 삭제
                        segment?[indexPath!.section].listCheckImageIndex.remove(at: indexPath!.row)
                    }
                    StopWatchDAO().deleteSegment(date: self.saveDate) // 데이터베이스에서 삭제
                    self.toDoTableView.reloadData()
                    self.calendarView.calendarView.reloadData()
                    self.closeListEditView()
                })

                self.present(alert, animated: false)
            }
            
        }
    }
    
    func closeListEditView(){
        if let editView = self.editListView {
            UIView.animate(withDuration: 0.3,animations: {
                editView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height + 40)
            }){ (_) in
                editView.removeFromSuperview() // 슈퍼뷰에서 제거!
                self.editListView = nil
            }
        }
    }
}
