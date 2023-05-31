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
    
    convenience init(_ date: String) {
        self.init()
        self.date = date
        self.totalTime = 0
        self.totalGoalTime = 0
        
        let realm = try! Realm()
        for seg in realm.objects(Segments.self) {
            let segmentData = SegmentData(date: date, segment: seg)
            self.dailySegment.append(segmentData)
        }
    }
}
