//
//  DateComponents+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/06.
//

import Foundation

extension DateComponents {
    var stringFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: Calendar.current.date(from: self)!)
    }
}
