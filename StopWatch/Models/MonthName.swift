//
//  MonthName.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/06.
//

import Foundation

enum MonthName: Int{
    case january = 1
    case february = 2
    case march = 3
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var title: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        }
    }
}

enum CalendarMode {
    case week
    case month
}
