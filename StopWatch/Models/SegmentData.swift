//
//  SegmentData.swift
//  StopWatch
//
//  Created by 신상우 on 2021/08/08.
//

import UIKit
import RealmSwift

class SegmentData: Object {
    @Persisted var date: String
    @Persisted var segment: Segments? // 세그먼트
    @Persisted var value: TimeInterval //한 시간
    @Persisted var goal: TimeInterval // 목표시간
    
    @Persisted var toDoList: List<String> //이 과목에서 해야할 일들
    @Persisted var listCheckImageIndex: List<Int> // 해야할 일들 체크 번호 0: 원, 1: 엑스, 2: 세모
    
    
    convenience init(date: String, segment: Segments? = nil) {
        self.init()
        self.date = date
        self.segment = segment
        self.value = 0
        self.goal = 0
    }
}


