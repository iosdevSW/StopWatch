//
//  Modeling.swift
//  StopWatch
//
//  Created by 신상우 on 2021/08/08.
//

import UIKit
import RealmSwift

struct checkImage {
    let images: [UIImage?] = [
        nil,
        UIImage(systemName: "circle"),
        UIImage(systemName: "triangle"),
        UIImage(systemName: "xmark")
    ]
}

struct Palette {
    
    var paints: [UIColor] = [
        UIColor(red: 180/255, green: 88/255, blue: 90/255, alpha: 1.0), /* #b4585a */
        UIColor(red: 251/255, green: 157/255, blue: 167/255, alpha: 1.0), /* #fb9da7 */
        UIColor(red: 252/255, green: 204/255, blue: 212/255, alpha: 1.0), /* #fcccd4 */
        UIColor(red: 208/255, green: 144/255, blue: 105/255, alpha: 1.0), /* #d09069 */
        UIColor(red: 251/255, green: 210/255, blue: 162/255, alpha: 1.0), /* #fbd2a2 */
        UIColor(red: 242/255, green: 226/255, blue: 198/255, alpha: 1.0), /* #f2e2c6 */
        UIColor(red: 103/255, green: 106/255, blue: 89/255, alpha: 1.0), /* #676a59 */
        UIColor(red: 142/255, green: 182/255, blue: 149/255, alpha: 1.0), /* #8eb695 */
        UIColor(red: 118/255, green: 138/255, blue: 162/255, alpha: 1.0), /* #768aa2 */
        UIColor(red: 163/255, green: 171/255, blue: 224/255, alpha: 1.0), /* #a3abe0 */
        UIColor(red: 71/255, green: 69/255, blue: 102/255, alpha: 1.0), /* #474566 */
        UIColor(red: 210/255, green: 188/255, blue: 225/255, alpha: 1.0), /* #d2bce1 */
        UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0), /* #ececec */
        UIColor(red: 206/255, green: 187/255, blue: 181/255, alpha: 1.0), /* #cebbb5 */
        UIColor(red: 134/255, green: 118/255, blue: 116/255, alpha: 1.0), /* #867674 */
        UIColor(red: 204/255, green: 158/255, blue: 142/255, alpha: 1.0), /* #cc9e8e */
        UIColor(red: 230/255, green: 213/255, blue: 195/255, alpha: 1.0), /* #e6d5c3 */
        UIColor(red: 236/255, green: 231/255, blue: 224/255, alpha: 1.0), /* #ece7e0 */
        UIColor(red: 218/255, green: 237/255, blue: 225/255, alpha: 1.0), /* #daede1 */
        UIColor(red: 171/255, green: 205/255, blue: 187/255, alpha: 1.0), /* #abcdbb */
        UIColor(red: 217/255, green: 221/255, blue: 168/255, alpha: 1.0), /* #d9dda8 */
        UIColor(red: 230/255, green: 237/255, blue: 206/255, alpha: 1.0), /* #e6edce */
        UIColor(red: 233/255, green: 241/255, blue: 233/255, alpha: 1.0), /* #e9f1e9 */
        UIColor(red: 239/255, green: 247/255, blue: 247/255, alpha: 1.0) /* #eff7f7 */
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
