//
//  DailyData.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/29.
//

import Foundation
import RealmSwift

class DailyData: Object {
    @Persisted(primaryKey: true) var date: String
    @Persisted var totalTime: TimeInterval
    @Persisted var totalGoalTime: TimeInterval
    @Persisted var dailySegment = List<SegmentData>()
    
    init(_ date: String) {
        super.init()
        self.date = date
        self.totalTime = 0
        self.totalGoalTime = 0
    }
}
