//
//  DateInfo.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/05.
//

import Foundation

class DateInfo {
    private let cal = Calendar.current
    var todayDate = DateComponents()
    var selectDate = DateComponents()
    
    init() {
        let date = Date()
        self.todayDate.year = self.cal.component(.year, from: date)
        self.todayDate.month = self.cal.component(.month, from: date)
        self.todayDate.day = self.cal.component(.day, from: date)
        
        self.selectDate = todayDate
    }
}
