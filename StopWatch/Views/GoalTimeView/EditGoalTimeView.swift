//
//  EditGoalTimeView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/07/27.
//

import UIKit

final class EditGoalTimeView: UIView {
    //MARK: - Properties
    private let hourArray = ["0시간","1시간","2시간","3시간","4시간","5시간","6시간","7시간","8시간",
                             "9시간","10시간","11시간","12시간","13시간","14시간","15시간","16시간",
                             "17시간","18시간","19시간","20시간","21시간","22시간","23시간"]
    
    private let minuteArray = ["00분","05분","10분","15분","20분","25분","30분",
                               "35분","40분","45분","50분","55분"]
    
    var selectedHour:TimeInterval = 0
    var selectedMinute:TimeInterval = 0
    
    var goal: TimeInterval = 0 // 현재 목표시간 받아올 변수
    var dailyData: DailyData?
    
    private let guideLabel = UILabel().then {
        $0.text = "' 목표시간 설정 '"
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 20)
    }
    
    let timePicker = UIPickerView().then {
        $0.backgroundColor = .white
    }
    
    let okButton = UIButton(type: .system).then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitle("OK", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 1
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.backgroundColor = .systemGray6
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 2
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
        self.addsubview()
        self.layout()
        
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    private func configure(){
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    //MARK: - Method
    private func getTimeInterval(text: String) -> TimeInterval {
        let newstring = text.filter { "0"..."9" ~= $0 }

        return TimeInterval(newstring)!
    }
    
    //MARK: - Selector
    
    //MARK: - AddSubView
    private func addsubview() {
        self.addSubview(self.guideLabel)
        self.addSubview(self.timePicker)
        self.addSubview(self.okButton)
        self.addSubview(self.cancelButton)
    }
    
    //MARK: - layOut
    private func layout() {
        self.guideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.timePicker.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.guideLabel.snp.bottom).offset(10)
            $0.height.equalTo(100)
        }
        
        self.okButton.snp.makeConstraints {
            $0.leading.equalTo(self.timePicker.snp.leading).offset(20)
            $0.trailing.equalTo(self.snp.centerX).offset(-10)
            $0.bottom.equalToSuperview().offset(-5)
            $0.height.equalTo(40)
        }
        
        self.cancelButton.snp.makeConstraints {
            $0.trailing.equalTo(self.timePicker.snp.trailing).offset(-20)
            $0.leading.equalTo(self.snp.centerX).offset(10)
            $0.bottom.equalToSuperview().offset(-5)
            $0.height.equalTo(40)
        }
    }
}
extension EditGoalTimeView: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? hourArray.count : minuteArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? hourArray[row] : minuteArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return NSAttributedString(string: hourArray[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }else {
            return NSAttributedString(string: minuteArray[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.selectedHour = getTimeInterval(text: hourArray[row]) * 60 * 60
        }else{
            self.selectedMinute = getTimeInterval(text: minuteArray[row]) * 60
        }
    }
}
