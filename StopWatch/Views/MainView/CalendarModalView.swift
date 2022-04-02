//
//  CalendarModalView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/04/01.
//

import UIKit
import RealmSwift

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
            self.titleView.label.text = CalendarMethod().convertDate(date: self.calendarView.saveDate) // 타이틀 날짜 다시표시
            
            let today = (UIApplication.shared.delegate as! AppDelegate).saveDate
            let formatter = DateFormatter()
            formatter.timeZone = .autoupdatingCurrent
            formatter.dateFormat = "YYYY.MM.dd"
            let date_today = formatter.date(from: today)
            let date_changeDate = formatter.date(from: self.changeDate)
            
            let result = date_today!.compare(date_changeDate!)
            switch result {
            case.orderedSame:
                self.compareDate = true
                break
            case.orderedAscending: fallthrough
            case.orderedDescending:
                self.compareDate = false
            }
        }
    }
    var compareDate: Bool = true {
        didSet{
            if compareDate == true{ // 오늘 날짜의 리스트 일때
                self.postponeButton.setTitle("내일 하기", for: .normal)
            }else { // 오늘 미만 또는 이상 날짜의 리스트 일때
                self.postponeButton.setTitle("오늘 하기", for: .normal)
            }
            
        }
    }
    
    let blurView: UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurView)
        effectView.alpha = 0.1
        effectView.translatesAutoresizingMaskIntoConstraints = false
        
        return effectView
    }()
    
    let selectedDateGuideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "선택한 날짜"
        label.textColor = .lightGray
        label.font = UIFont(name: "GodoM", size: 12)
        
        return label
    }()
    
    let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont(name: "GodoM", size: 24)
       
        return label
    }()
    
    let frameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.darkGray.cgColor
        
        return view
    }()
    
    let titleView: TitleView = {
        let view = TitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.label.font = UIFont(name: "GodoM", size: 16)
        
        return view
    }()

    let calendarView: CalendarView = {
        let view = CalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendarMode = .month
        view.calendarView.layer.cornerRadius = 20
        view.collectionHeaderView.layer.cornerRadius = 20
        view.calendarInfo.cellSize = (UIScreen.main.bounds.width - 60) / 7
        
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
    
    let okButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 6
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitle("확 인", for: .normal)
        button.titleLabel?.font = UIFont(name: "GodoM", size: 14)
        
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 6
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitle("취 소", for: .normal)
        button.titleLabel?.font = UIFont(name: "GodoM", size: 14)
        
        return button
    }()
    
    let postponeButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 6
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitle("내일 하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "GodoM", size: 14)
        
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.blurView)
        self.addSubview(self.frameView)
        
        self.frameView.addSubview(self.selectedDateGuideLabel)
        self.frameView.addSubview(self.selectedDateLabel)
        self.frameView.addSubview(self.previousMonthButton)
        self.frameView.addSubview(self.nextMonthButton)
        self.frameView.addSubview(self.titleView)
        self.frameView.addSubview(self.calendarView)
        self.frameView.addSubview(self.okButton)
        self.frameView.addSubview(self.postponeButton)
        self.frameView.addSubview(self.cancelButton)
        
        self.addTarget()
        
        self.calendarView.saveDateDelegate = self
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    func closeModalView(){
        self.removeFromSuperview()
    }
    
    //MARK: - AddTarget
    func addTarget(){
        self.nextMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.previousMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
    
        self.cancelButton.addTarget(self, action: #selector(self.clickCancelButton(_:)), for: .touchUpInside)
    }
    //MARK: - Selector
    
    @objc func respondToButton(_ button:UIButton){
        let (year,month,day) = CalendarMethod().changeMonth(tag: button.tag, date: self.calendarView.presentDate)
        
        self.calendarView.presentDate = String(year) + "." + self.returnString(month) + "." + self.returnString(day)
        
        // 바뀐 값 캘린더뷰로 전달하고 컬렉션뷰 리로드
        self.calendarView.calendarView.reloadData()
        self.titleView.label.text = CalendarMethod().convertDate(date: self.calendarView.presentDate) // 타이틀 날짜 다시표시
    }

    @objc func clickCancelButton(_ sender: UIButton){
        self.closeModalView()
    }
    
    //MARK: - layout
    func layout() {
        NSLayoutConstraint.activate([
            self.blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.blurView.topAnchor.constraint(equalTo: self.topAnchor),
            self.blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.selectedDateGuideLabel.topAnchor.constraint(equalTo: self.frameView.topAnchor, constant: 10),
            self.selectedDateGuideLabel.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 10),
        ])
        
        NSLayoutConstraint.activate([
            self.selectedDateLabel.topAnchor.constraint(equalTo: self.selectedDateGuideLabel.bottomAnchor, constant: 10),
            self.selectedDateLabel.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            self.frameView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.frameView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            self.frameView.heightAnchor.constraint(equalToConstant: 400),
            self.frameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.titleView.topAnchor.constraint(equalTo: self.selectedDateLabel.bottomAnchor, constant: 20),
            self.titleView.leadingAnchor.constraint(equalTo: self.calendarView.leadingAnchor),
            self.titleView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            self.calendarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            self.calendarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            self.calendarView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor),
            self.calendarView.heightAnchor.constraint(equalToConstant: 240)
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
            self.okButton.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 10),
            self.okButton.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor, constant: -10),
            self.okButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        NSLayoutConstraint.activate([
            self.cancelButton.leadingAnchor.constraint(equalTo: self.okButton.trailingAnchor, constant: 10),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor, constant: -10),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40),
            self.cancelButton.widthAnchor.constraint(equalTo: self.okButton.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.postponeButton.leadingAnchor.constraint(equalTo: self.cancelButton.trailingAnchor, constant: 10),
            self.postponeButton.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor, constant: -10),
            self.postponeButton.heightAnchor.constraint(equalToConstant: 40),
            self.postponeButton.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -10),
            self.postponeButton.widthAnchor.constraint(equalTo: self.okButton.widthAnchor)
        ])
    }
    
}

extension CalendarModalView: SaveDateDetectionDelegate{
    func detectSaveDate(date: String) {
        let (year,month,day): (String,String,String) = CalendarMethod().splitDate(date: date)
        self.selectedDateLabel.text = year + "년 " + month + "월 " + day + "일"
        self.saveDate = date
    }
    
    
}
