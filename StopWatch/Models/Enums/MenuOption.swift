//
//  MenuOption.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit

enum MenuOption: Int,CustomStringConvertible {
    case category
    case goalTime
    case dDay
    case contact
    case logout
    case statistics
    
    var description: String {
        switch self {
        case .category: return "Category"
        case .goalTime: return "SetGoalTime"
        case .dDay: return "D-Day"
        case .statistics: return "Statistics"
        case .contact: return "Contact"
        case .logout: return "Logout"
        }
    }
    
    var image: UIImage {
        switch self {
        case .category: return UIImage(named: "category") ?? UIImage()
        case .goalTime: return UIImage(named: "goalTime") ?? UIImage()
        case .dDay: return UIImage(named: "dday") ?? UIImage()
        case .statistics: return UIImage(named: "statistics") ?? UIImage()
        case .contact: return UIImage(named: "contact") ?? UIImage()
        case .logout: return UIImage(systemName: "rectangle.portrait.and.arrow.forward") ?? UIImage()
        }
    }
}


