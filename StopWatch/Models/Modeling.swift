//
//  Modeling.swift
//  StopWatch
//
//  Created by 신상우 on 2021/08/08.
//

import UIKit
import RealmSwift

enum CheckImage: Int {
    case null
    case circle
    case triangle
    case xmark
    
    var image: UIImage {
        switch self {
        case .null: return UIImage()
        case .circle: return UIImage(systemName: "circle") ?? UIImage()
        case .triangle: return UIImage(systemName: "triangle") ?? UIImage()
        case .xmark: return UIImage(systemName: "xmark") ?? UIImage()
        }
    }
}
//struct CheckImage {
//    let images: [UIImage?] = [
//        nil,
//        UIImage(systemName: "circle"),
//        UIImage(systemName: "triangle"),
//        UIImage(systemName: "xmark")
//    ]
//}

struct Palette {
    
    var paints: [Int] = [
        0xB4585A, /* #b4585a */
        0xFB9DA7, /* #fb9da7 */
        0xFCCCD4, /* #fcccd4 */
        0xD09069, /* #d09069 */
        0xFBD2A2, /* #fbd2a2 */
        0xF2E2C6, /* #f2e2c6 */
        0x676A59, /* #676a59 */
        0x8EB695, /* #8eb695 */
        0x768AA2, /* #768aa2 */
        0xA3ABE0, /* #a3abe0 */
        0x474566, /* #474566 */
        0xd2bce1, /* #d2bce1 */
        0xECECEC, /* #ececec */
        0xCEBBB5, /* #cebbb5 */
        0x867674, /* #867674 */
        0xCC9E8E, /* #cc9e8e */
        0xE6D5C3, /* #e6d5c3 */
        0xECE7E0, /* #ece7e0 */
        0xDAEDE1, /* #daede1 */
        0xABCDBB, /* #abcdbb */
        0xD9DDA8, /* #d9dda8 */
        0xE6EDCE, /* #e6edce */
        0xE9F1E9, /* #e9f1e9 */
        0xEFF7F7  /* #eff7f7 */
    ]
    
}

class Palettes: Object {
    @Persisted var colorCode: Int // 16진수 색상코드 (UIColor는 저장 안되니까 코드로 저장)
}

class Segments: Object {
    @Persisted(primaryKey: true) var id : String = UUID().uuidString // 과목번호
    @Persisted var name: String // 과목명
    @Persisted var colorCode: Int //과목색상코드
}

class SegmentData: Object {
    @Persisted var date: String
    @Persisted var segment: Segments? // 세그먼트
    @Persisted var value: TimeInterval //한 시간
    @Persisted var goal: TimeInterval // 목표시간
    
    @Persisted var toDoList: List<String> //이 과목에서 해야할 일들
    @Persisted var listCheckImageIndex: List<Int> // 해야할 일들 체크 번호 0: 원, 1: 엑스, 2: 세모
}

class DailyData: Object {
    @Persisted(primaryKey: true) var date: String
    @Persisted var totalTime: TimeInterval
    @Persisted var totalGoalTime: TimeInterval
    @Persisted var dailySegment = List<SegmentData>()
    
}

struct CalendarViewInfo{
    var cellSize: CGFloat?
    var getCalendarViewWidth: CGFloat {
        return cellSize! * CGFloat(widthNumberOfCell)
    }
    var getCalendarViewHeight: CGFloat {
        return cellSize! * CGFloat(heightNumberOfCell!)
    }
    let widthNumberOfCell = 7
    var heightNumberOfCell:Int?
    var numberOfItem: Int {
        return widthNumberOfCell * (heightNumberOfCell! - 1) // - 1은 요일 표기하는 헤더 셀 크기 빼주기.
    }
    var dayArray = ["S","M","T","W","T","F","S"]
}

class SingleTon {
    static let shared = SingleTon()
    
    var cellSize: CGFloat?
}
