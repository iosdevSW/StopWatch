//
//  CalendarView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/17.
//

import UIKit
import RealmSwift
import Then
import SnapKit

final class CalendarView: UIView,UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: - Properties
    private let realm = try! Realm()
    let calendarMethod = CalendarMethod()
    weak var modalCalendarDelegate: ChangeSelectDateDelegate?
    
    private let calendar = Calendar.current
    var currentCalendarComponent = DateComponents() // 현재 달력의 보여지는 년/달
    var selectDateComponent = DateComponents() //선택한 날짜
    var todayDateComponent = DateComponents() // 오늘 날짜
    
    private let dayArray = ["S","M","T","W","T","F","S"]
    private var days = [String]()
    
    var calendarMode: CalendarMode = .week {
        didSet{
            guard let layout = self.calendarView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            layout.scrollDirection = calendarMode == .week ? .horizontal : .vertical
        }
    }
    
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
    }
    
    let yearMonthLabel = UILabel().then {
        $0.font = UIFont(name: "GodoM", size: 24)
        $0.text = "22 December"
        $0.backgroundColor = .white
    }
    
    private let previousMonthButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = .darkGray
        $0.tag = 0
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
    
    let changeCalendarMode = UIButton(type: .system).then {
        $0.setTitle("주▾", for: .normal)
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
        $0.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    private let collectionHeaderView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
        $0.tag = 0
    }
    
    let calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout().then { $0.scrollDirection = .horizontal }
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
            $0.backgroundColor = .white
            $0.showsHorizontalScrollIndicator = false
            $0.isPagingEnabled = true // 페이징 스크롤 처리
            $0.tag = 1
            $0.clipsToBounds = false
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.collectionHeaderView.delegate = self
        self.collectionHeaderView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        
        self.setTodayDate()
        self.dateCalculate()
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    private func setTodayDate() {
        let date = Date()
        self.todayDateComponent.year = calendar.component(.year, from: date)
        self.todayDateComponent.month = calendar.component(.month, from: date)
        self.todayDateComponent.day = calendar.component(.day, from: date)
        
        self.selectDateComponent = self.todayDateComponent
        
        self.currentCalendarComponent = self.todayDateComponent
        self.currentCalendarComponent.day = 1
    }
    
    private func dateCalculate() {
        let firstDayOfMonth = self.calendar.date(from: self.currentCalendarComponent)
        let weekDay = calendar.component(.weekday, from: firstDayOfMonth!)
        let daysOfMonth = calendarMethod.getLastDayOfMonth(self.currentCalendarComponent)
        let weekDayAdding = 2 - weekDay
        self.yearMonthLabel.text = calendarMethod.convertYearMonth(self.currentCalendarComponent)

        self.days = []
        for day in weekDayAdding...daysOfMonth {
            if day < 1 {
                days.append("")
            } else {
                self.days.append(String(day))
            }
        }
    }
    
    ///데이터 있는지 체크하는 함수
    private func isData(_ day: String)-> Bool {
        guard let day = Int(day) else { return false }
        var tempComponent = self.currentCalendarComponent
        tempComponent.day = day
        let dateString = dateFormatter.string(from: calendar.date(from: tempComponent)!)
        if realm.object(ofType: DailyData.self, forPrimaryKey: dateString) == nil {
            return false
        } else {
            return true
        }
    }
    
    func getSelectDateString() -> String{
        guard let year = self.selectDateComponent.year,
              let month = self.selectDateComponent.month,
              let day = self.selectDateComponent.day else { return "" }
        
        return "\(year)년 \(month)월 \(day)일"
    }
    
    //MARK: - Selector
    @objc func didClickChangeCalendarMode(_ sender: UIButton) {
        NotificationCenter.default.post(name: .changeCalendarMode, object: nil)
    }
    
    @objc func didChangeMonth(_ button: UIButton) {
        self.currentCalendarComponent = calendarMethod.changeMonth(self.currentCalendarComponent, tag: button.tag)
        self.dateCalculate()
        self.calendarView.reloadData()
    }
    
    //MARK: - addsubview
    private func addSubView(){
        self.addSubview(self.yearMonthLabel)
        self.addSubview(self.previousMonthButton)
        self.addSubview(self.nextMonthButton)
        self.addSubview(self.changeCalendarMode)
        self.addSubview(self.collectionHeaderView)
        self.addSubview(self.calendarView)
    }
    
    //MARK: - layout
    private func layout(){
        self.yearMonthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        self.previousMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.yearMonthLabel.snp.trailing).offset(10)
            make.height.width.equalTo(28)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
        }
        
        self.nextMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.previousMonthButton.snp.trailing).offset(4)
            make.height.width.equalTo(28)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
        }
        
        self.changeCalendarMode.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-30)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
            make.height.equalTo(28)
            make.width.equalTo(34)
        }
        
        self.collectionHeaderView.snp.makeConstraints { make in
            make.top.equalTo(self.yearMonthLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(32)
        }
        
        self.calendarView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(self.collectionHeaderView.snp.bottom)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.changeCalendarMode.addTarget(self, action: #selector(self.didClickChangeCalendarMode(_:)), for: .touchUpInside)
        self.nextMonthButton.addTarget(self, action: #selector(self.didChangeMonth(_:)), for: .touchUpInside)
        self.previousMonthButton.addTarget(self, action: #selector(self.didChangeMonth(_:)), for: .touchUpInside)
    }
    
    //MARK: - CollectionView Delegate,DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 0 ? self.dayArray.count : self.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath) as! CalendarCell
        
        if collectionView == self.collectionHeaderView  {
            cell.configureHeaderCell(indexPath.row)
            cell.dateLabel.text = self.dayArray[indexPath.row]
        } else {
            cell.configureCell()
            cell.dataCheckView.isHidden = !isData(days[indexPath.row])
            cell.dateLabel.text = days[indexPath.row]
            if let day = Int(days[indexPath.row]) {
                var tempComponent = self.currentCalendarComponent
                tempComponent.day = day
                let bgColor = self.selectDateComponent.stringFormat == tempComponent.stringFormat ? UIColor.standardColor : UIColor.white
                cell.backgroundColor = bgColor
            } else {
                cell.isUserInteractionEnabled = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            self.selectDateComponent = currentCalendarComponent
            self.selectDateComponent.day = Int(days[indexPath.row])!
            self.dateCalculate()
            self.calendarView.reloadData()
            
            if let delegate = self.modalCalendarDelegate { // modalCalendarView일 경우
                delegate.changeSelectDate()
            } else { // 기본 캘린더일 경우
                NotificationCenter.default.post(name: .changeSaveDate,
                                                object: nil,
                                                userInfo: ["selectedDate" : self.selectDateComponent.stringFormat])
            }
        }
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    //뷰 크기 리턴
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: (UIScreen.main.bounds.size.width - 20) / 7,
            height: 32
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

