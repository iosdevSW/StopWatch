//
//  DdayViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/15.
//

import UIKit
import Then
import SnapKit

final class DdayViewController: UIViewController{
    //MARK: - Properties
    private var dday: Date!
    
    private let ddayLabel = UILabel().then {
        $0.text = "D-0"
        $0.font = .systemFont(ofSize: 30)
        $0.textColor = .darkGray
    }
    
    private let guideLabel = UILabel().then {
        $0.text = "목표 날짜를 입력하세요."
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 22)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = " "
        $0.textColor = UIColor(red: 134/255, green: 118/255, blue: 116/255, alpha: 1.0)
        $0.font = .systemFont(ofSize: 24, weight: .semibold )
    }
    
    private let datePickerView = UIDatePicker().then {
        $0.preferredDatePickerStyle = .wheels
        $0.datePickerMode = .date
        $0.locale = Locale(identifier: "ko-KR")
        $0.timeZone = .autoupdatingCurrent
        $0.minimumDate = Date() // 최소 오늘 이상
    }
    
    private let okButton = UIButton(type: .roundedRect).then {
        $0.layer.cornerRadius = 10
        $0.setTitle("확 인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 134/255, green: 118/255, blue: 116/255, alpha: 1.0)
    }
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.configureNavigationBar()
        
        self.dday = UserDefaults.standard.value(forKey: "dday") as? Date ?? Date()
        self.datePickerView.date = self.dday
        self.returnDday(self.dday)
        self.dateLabel.text = self.returnToday(self.dday)
    }
    
    private func returnDday(_ date: Date){
        let dayCount = Double(date.timeIntervalSinceNow / 86400) // 하루86400초
        let dday =  Int(ceil(dayCount)) // 소수점 올림
        let text = dday >= 0 ? "D-" + "\(dday)" : "D+" + "\(abs(dday))"
        self.ddayLabel.text = text
    }
    
    private func returnToday(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 MM월 dd일"
        
        return formatter.string(from: date)
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        _ = UILabel().then {
            $0.text = "공부 습관"
            $0.textColor = .darkGray
            $0.font = UIFont(name: "GodoM", size: 18)
            
            self.navigationItem.titleView = $0
        }
    }
    
    //MARK: - Selector
    @objc func didChangeDate(){
        self.dday = self.datePickerView.date
        self.dateLabel.text = self.returnToday(self.dday)
        self.returnDday(self.dday)
    }
    
    @objc func didClickOKButton(){
        let ud = UserDefaults.standard
        ud.setValue(self.dday, forKey: "dday")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.view.addSubview(self.ddayLabel)
        self.view.addSubview(self.guideLabel)
        self.view.addSubview(self.dateLabel)
        self.view.addSubview(self.datePickerView)
        self.view.addSubview(self.okButton)
    }
    
    //MARK: - layout
    private func layout(){
        self.ddayLabel.snp.makeConstraints {
            $0.top.equalTo(self.datePickerView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        self.guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(200)
        }
        
        self.dateLabel.snp.makeConstraints {
            $0.top.equalTo(self.guideLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        self.datePickerView.snp.makeConstraints {
            $0.top.equalTo(self.dateLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        self.okButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-50)
            $0.leading.equalToSuperview().offset(50)
            $0.height.equalTo(50)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.datePickerView.addTarget(self, action: #selector(self.didChangeDate), for: .valueChanged)
        self.okButton.addTarget(self, action: #selector(self.didClickOKButton), for: .touchUpInside)
    }
}
