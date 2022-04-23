//
//  DdayViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/15.
//

import UIKit

class DdayViewController: UIViewController{
    //MARK: - Properties
    var dday: Date!
    
    let ddayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "D-0"
        label.font = .systemFont(ofSize: 30)
        label.textColor = .darkGray
        
        return label
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "목표 날짜를 입력하세요."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 22)
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        label.textColor = UIColor(red: 134/255, green: 118/255, blue: 116/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 24, weight: .semibold )
        
        return label
    }()
    
    let datePickerView: UIDatePicker = {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.preferredDatePickerStyle = .wheels
        view.datePickerMode = .date
        view.locale = Locale(identifier: "ko-KR")
        view.timeZone = .autoupdatingCurrent
        view.minimumDate = Date() // 최소 오늘 이상
        
        return view
    }()
    
    let okButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("확 인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 134/255, green: 118/255, blue: 116/255, alpha: 1.0)
        
        return button
    }()
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addsubView()
        self.layout()
       
        self.datePickerView.addTarget(self, action: #selector(self.didChangeDate), for: .valueChanged)
        self.okButton.addTarget(self, action: #selector(self.clickOKButton), for: .touchUpInside)
        
        self.navigationController?.navigationBar.isHidden = false
        
        let label = UILabel()
        label.text = "공부 습관"
        label.textColor = .darkGray
        label.font = UIFont(name: "GodoM", size: 18)
        self.navigationItem.titleView = label
        
        self.dday = UserDefaults.standard.value(forKey: "dday") as? Date ?? Date()
        self.datePickerView.date = self.dday
        self.returnDday(date: self.dday)
        self.dateLabel.text = self.returnToday(date: self.dday)
    }
    
    func returnDday(date: Date){
        let dayCount = Double(date.timeIntervalSinceNow / 86400) // 하루86400초
        let dday =  Int(ceil(dayCount)) // 소수점 올림
        if dday >= 0 {
            self.ddayLabel.text = "D-" + "\(dday)"
        }else {
            self.ddayLabel.text = "D+" + "\(abs(dday))"
        }
        
    }
    
    func returnToday(date: Date) -> String{
        let date = date
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    //MARK: - Selector
    @objc func didChangeDate(){
        self.dday = self.datePickerView.date
        self.dateLabel.text = self.returnToday(date: self.dday)
        self.returnDday(date: self.dday)
    }
    
    @objc func clickOKButton(){
        let ud = UserDefaults.standard
        ud.setValue(self.dday, forKey: "dday")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - AddsubView
    func addsubView() {
        self.view.addSubview(self.ddayLabel)
        self.view.addSubview(self.guideLabel)
        self.view.addSubview(self.dateLabel)
        self.view.addSubview(self.datePickerView)
        self.view.addSubview(self.okButton)
    }
    
    //MARK: - layout
    func layout(){
        NSLayoutConstraint.activate([
            self.ddayLabel.topAnchor.constraint(equalTo: self.datePickerView.bottomAnchor, constant: 20),
            self.ddayLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.guideLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.guideLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200)
        ])
        
        NSLayoutConstraint.activate([
            self.dateLabel.topAnchor.constraint(equalTo: self.guideLabel.bottomAnchor, constant: 20),
            self.dateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.datePickerView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 10),
            self.datePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.datePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.datePickerView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        NSLayoutConstraint.activate([
            self.okButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            self.okButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            self.okButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            self.okButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
