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

protocol ChangeSelectDateDelegate: AnyObject {
    func changeSelectDate()
}

final class CalendarModalView: UIView {
    //MARK: - Properties
    var indexPath: IndexPath!
    var changeDateComponent = DateComponents()
    
    private var isTodayDate: Bool = true {
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

    lazy var calendarView = CalendarView().then {
        $0.calendarMode = .month
        $0.calendarView.layer.cornerRadius = 20
        $0.calendarInfo.cellSize = (UIScreen.main.bounds.width - 60) / 7
        $0.yearMonthLabel.font = UIFont(name: "GodoM", size: 16)
        $0.modalCalendarDelegate = self
    }
    
    private let okButton = UIButton(type: .roundedRect).then {
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
    
    private let postponeButton = UIButton(type: .roundedRect).then {
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
    init(_ selectDateComponent: DateComponents) {
        self.changeDateComponent = selectDateComponent
        
        super.init(frame: .zero)
        self.addSubView()
        self.addTarget()
        self.layout()
        
        self.calendarView.selectDateComponent = self.changeDateComponent
        
        self.selectedDateLabel.text = self.calendarView.getSelectDateString()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.isTodayDate = CalendarMethod().isTodayDate(self.changeDateComponent)
    }
    
    //MARK: - Method
    func changeDateTodoList(){
        let toSegment = StopWatchDAO().getSegment(self.changeDateComponent.stringFormat, section: indexPath.section)
        let fromSegment = StopWatchDAO().getSegment(self.calendarView.selectDateComponent.stringFormat, section: indexPath.section)
     
        let alert = UIAlertController(title: nil, message: "선 택", preferredStyle: .alert)
        let move = UIAlertAction(title: "이동하기", style: .default){ [weak self] _ in
            guard let self else { return }
            _ = StopWatchDAO().moveTodoList(to: toSegment, from: fromSegment, row: self.indexPath.row)
            StopWatchDAO().deleteSegment(date: self.changeDateComponent.stringFormat)
            
            NotificationCenter.default.post(name: .changeSaveDate, object: nil)
            self.removeFromSuperview()
        }
        
        let copy = UIAlertAction(title: "복사하기", style: .default){ [weak self] _ in
            guard let self else { return }
            _ = StopWatchDAO().copyTodoList(to: toSegment, from: fromSegment, row: self.indexPath.row)
            
            NotificationCenter.default.post(name: .changeSaveDate, object: nil)
            self.removeFromSuperview()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [move,copy,cancel].forEach { alert.addAction($0) }
        
        NotificationCenter.default.post(name: .presentAlert, object: nil, userInfo: ["alert" : alert])
    }
    
    //MARK: - Selector
    @objc func clickCancelButton(_ sender: UIButton){
        self.removeFromSuperview()
    }
    
    @objc func clickOkButton(_ sender: UIButton){
        let _ = StopWatchDAO().create(date: self.calendarView.selectDateComponent.stringFormat)
        
        self.changeDateTodoList()
    }
    
    @objc func postponeList(sender: UIButton){
        let todayComponents = self.calendarView.todayDateComponent
        
        if self.isTodayDate { // 오늘 데이터라면
            if CalendarMethod().isLastDayOfMonth(todayComponents) { //오늘이 달의 마지막 날이라면
                self.calendarView.selectDateComponent = CalendarMethod().changeMonth(todayComponents, tag: 1) // 다음 달 1일로 설정
                self.calendarView.selectDateComponent.day = 1
            } else { // 오늘이 달의 마지막이 아니라면
                self.calendarView.selectDateComponent.day = self.calendarView.selectDateComponent.day! + 1 // 내일로 설정
            }
        } else { // 오늘 데이터가 아니라면
            self.calendarView.selectDateComponent = todayComponents // 오늘로 설정
        }
        
        let _ = StopWatchDAO().create(date: CalendarMethod().componentToDateString(self.calendarView.selectDateComponent))// 선택한 날짜 데이터 생성
        
        self.changeDateTodoList()
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
    private func addTarget() {
        self.cancelButton.addTarget(self, action: #selector(self.clickCancelButton(_:)), for: .touchUpInside)
        self.okButton.addTarget(self, action: #selector(self.clickOkButton(_:)), for: .touchUpInside)
        self.postponeButton.addTarget(self, action: #selector(self.postponeList(sender:)), for: .touchUpInside)
    }
}

// 저장할 날짜가 변경되었을 경우
extension CalendarModalView: ChangeSelectDateDelegate {
    func changeSelectDate() {
        self.selectedDateLabel.text = self.calendarView.getSelectDateString()
        self.isTodayDate = CalendarMethod().isTodayDate(self.calendarView.selectDateComponent)
    }
}
