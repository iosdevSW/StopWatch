//
//  StopWatchDAO.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/12.
//

import UIKit
import RealmSwift

class StopWatchDAO {
    let realm = try! Realm()
    
    func create(date: String){ // 오늘의 데이터가 없을 때 오늘 데이터를 생성하는 함수
        if let _ = self.realm.object(ofType: DailyData.self, forPrimaryKey: date) {
        } else {
            try! realm.write{
                let day = DailyData() // 오늘 데이터 생성
                day.date = date
                day.totalGoalTime = 0
                day.totalTime = 0
                let totalSeg = realm.objects(Segments.self)
                
                for seg in totalSeg {
                    let object = SegmentData() // 오늘 과목들 생성
                    object.date = date
                    object.goal = 0
                    object.value = 0
                    object.segment = seg
                    realm.add(object)
                    
                    day.dailySegment.append(object) // 오늘 데이터에 오늘 과목들 넣기
                }
                
                realm.add(day)
            }
        }
    }
    
    //과목 추가 메소드
    func addSegment(row: Int, name: String, date: String){
       
        try! realm.write{
            let segment = Segments() // 과목리스트 추가
            segment.colorCode = row
            segment.name = name
            
            realm.add(segment)
            
            let segmentData = SegmentData() // 오늘의 과목에 추가
            segmentData.date = date
            segmentData.goal = 0
            segmentData.value = 0
            segmentData.segment = segment
            
            realm.add(segmentData)
            
            let dailyData = realm.object(ofType: DailyData.self, forPrimaryKey: date) // 오늘 데이터 불러오기
        
            dailyData?.dailySegment.append(segmentData) // 오늘 데이터에 추가한 과목 추가
        }
    }

    func deleteSegment(date: String){
        // 해당 날짜에 빈 segmentData 가 있는지 확인
        let blankSegmentData = self.realm.objects(SegmentData.self).where {
            ($0.value == 0) && ($0.goal == 0) && ($0.toDoList.count == 0) && ($0.date == date)
        }
        
        // 해당 날짜에 모든 segmentData 가 비었으면 해당 날짜 데이터 모두 삭제
        if (blankSegmentData.count) == (self.realm.objects(Segments.self).count) {
            try! realm.write{
                guard let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: date) else { return }
                self.realm.delete(dailyData)
                for segData in blankSegmentData {
                    self.realm.delete(segData)
                }
            }
        }
    }
    
    func checkSegmentData(date: String){
        let segmentData = self.realm.objects(SegmentData.self).where {
            $0.date == date
        }
        let segemnts = self.realm.objects(Segments.self)
        guard let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: date) else { return }
        
        for segment in segemnts {
            let isSeg = segmentData.contains{ seg in seg.segment == segment }
            if isSeg == false {
                try! self.realm.write{
                    let object = SegmentData() // 오늘 과목들 생성
                    object.date = date
                    object.goal = 0
                    object.value = 0
                    object.segment = segment
                    realm.add(object)
                    
                    dailyData.dailySegment.append(object)
                }
            }
        }
    }

    
}

