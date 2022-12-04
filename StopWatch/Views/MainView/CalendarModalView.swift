//
//  CalendarModalView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/04/01.
//

import UIKit
import RealmSwift
import Then
import SnapKit

class CalendarModalView: UIView {
    //MARK: - Properties
    var saveDate = "" {
        didSet{
            let (year,month,day): (String,String,String) = CalendarMethod().splitDate(date: self.saveDate)
            self.selectedDateLabel.text = year + "년 " + month + "월 " + day + "일"
        }
    }
    var indexpath: IndexPath!
    var changeDate = "" {
        didSet{
            self.calendarView.yearMonthLabel.text = CalendarMethod().convertDate(date: self.calendarView.saveDate) // 타이틀 날짜 다시표시
            
            let today = (UIApplication.shared.delegate as! AppDelegate).resetDate
            let formatter = DateFormatter()
            formatter.timeZone = .autoupdatingCurrent
            formatter.dateFormat = "YYYY.MM.dd"
            let date_today = formatter.date(from: today)
            let date_changeDate = formatter.date(from: self.changeDate)
            
            let result = date_today!.compare(date_changeDate!)
            switch result {
            case.orderedSame:
                self.isTodayDate = true
                break
            case.orderedAscending: fallthrough
            case.orderedDescending:
                self.isTodayDate = false
            }
        }
    }
    var isTodayDate: Bool = true {
        didSet{
            let title = self.isTodayDate ? "내일 하기" : "오늘 하기"
            self.postponeButton.setTitle(title, for: .normal)
        }
    }
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.alpha = 0.1
    }
    
    private let selectedDateGuideLabel = UILabel().then {
        $0.text = "선택한 날짜"
        $0.textColor = .lightGray
        $0.font = UIFont(name: "GodoM", size: 12)
    }
    
    private let selectedDateLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont(name: "GodoM", size: 24)
    }
    
    private let frameView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowOpacity = 0.7
        $0.layer.shadowOffset = .zero
        $0.layer.shadowColor = UIColor.darkGray.cgColor
    }

    let calendarView = CalendarView().then {
        $0.calendarMode = .month
        $0.calendarView.layer.cornerRadius = 20
        $0.collectionHeaderView.layer.cornerRadius = 20
        $0.calendarInfo.cellSize = (UIScreen.main.bounds.width - 60) / 7
        $0.yearMonthLabel.font = UIFont(name: "GodoM", size: 16)
    }
    
    let okButton = UIButton(type: .roundedRect).then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 6
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.setTitle("확 인", for: .normal)
        $0.titleLabel?.font = UIFont(name: "GodoM", size: 14)
    }
    
    private let cancelButton = UIButton(type: .roundedRect).then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 6
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.setTitle("취 소", for: .normal)
        $0.titleLabel?.font = UIFont(name: "GodoM", size: 14)
    }
    
    let postponeButton = UIButton(type: .roundedRect).then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 6
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.setTitle("내일 하기", for: .normal)
        $0.titleLabel?.font = UIFont(name: "GodoM", size: 14)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [okButton, cancelButton, postponeButton]).then {
        $0.spacing = 10
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.addTarget()
        self.layout()
        
        self.calendarView.saveDateDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    
    //MARK: - Selector
    
    @objc func respondToButton(_ button:UIButton){
        let (year,month,day) = CalendarMethod().changeMonth(tag: button.tag, date: self.calendarView.presentDate)
        self.calendarView.presentDate = String(year) + "." + self.returnString(month) + "." + self.returnString(day)
        
        // 바뀐 값 캘린더뷰로 전달하고 컬렉션뷰 리로드
        self.calendarView.calendarView.reloadData()
        self.calendarView.yearMonthLabel.text = CalendarMethod().convertDate(date: self.calendarView.presentDate) // 타이틀 날짜 다시표시
    }

    @objc func clickCancelButton(_ sender: UIButton){
        self.removeFromSuperview()
    }
    
    @objc func clickOkButton(_ sender: UIButton){
        let _ = StopWatchDAO().create(date: self.saveDate)
        let (section,row) = (indexpath.section,indexpath.row)
        
        NotificationCenter.default.post(name: .changeModalCalendarViewDate, object: nil, userInfo: ["modalView": self,
                                                                                                    "indexPath": (section,row)])
    }
    
    @objc func postponeList(sender: UIButton){
        let today = (UIApplication.shared.delegate as! AppDelegate).resetDate
        let (section,row) = (indexpath.section,indexpath.row)
        var date = ""
        
        var (intYear,intMonth,intDay): (Int,Int,Int) = CalendarMethod().splitDate(date: today)
        let lastDayOfMonth = CalendarMethod().getDaysOfMonth(year: intYear, month: intMonth)
        
        if self.isTodayDate { // 수정 필요
            if intDay == lastDayOfMonth {
                let (year,month,_) = CalendarMethod().changeMonth(tag: 1, date: today)
                intYear = year
                intMonth = month
                intDay = 1
            }else {
                intDay += 1
            }
            date = String(intYear) + "." + self.returnString(intMonth) + "." + self.returnString(intDay)
        }else {
            date = today
        }
        
        self.saveDate = date
        self.calendarView.saveDate = date
        self.calendarView.presentDate = date
        self.calendarView.calendarView.reloadData()
        self.calendarView.yearMonthLabel.text = CalendarMethod().convertDate(date: date)
        
        let _ = StopWatchDAO().create(date: self.saveDate)
        NotificationCenter.default.post(name: .changeModalCalendarViewDate, object: nil, userInfo: ["modalView": self,
                                                                                                    "indexPath": (section,row)])
    }
    
    //MARK: - addSubView
    private func addSubView() {
        self.addSubview(self.blurView)
        self.addSubview(self.frameView)
        
        self.frameView.addSubview(self.selectedDateGuideLabel)
        self.frameView.addSubview(self.selectedDateLabel)
        self.frameView.addSubview(self.calendarView)
        self.frameView.addSubview(self.stackView)
    }
    
    //MARK: - layout
    private func layout() {
        self.blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.selectedDateGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
        }
        
        self.selectedDateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.top.equalTo(self.selectedDateGuideLabel.snp.bottom).offset(10)
        }
        
        self.frameView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        self.calendarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.selectedDateLabel.snp.bottom).offset(20)
            $0.height.equalTo(240)
        }
        
        self.stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(40)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget(){
        self.cancelButton.addTarget(self, action: #selector(self.clickCancelButton(_:)), for: .touchUpInside)
        self.okButton.addTarget(self, action: #selector(self.clickOkButton(_:)), for: .touchUpInside)
        self.postponeButton.addTarget(self, action: #selector(self.postponeList(sender:)), for: .touchUpInside)
    }
}

extension CalendarModalView: SaveDateDetectionDelegate{
    func detectSaveDate(date: String) {
        let (year,month,day): (String,String,String) = CalendarMethod().splitDate(date: date)
        self.selectedDateLabel.text = year + "년 " + month + "월 " + day + "일"
        self.saveDate = date
    }
}
