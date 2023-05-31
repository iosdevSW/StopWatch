//
//  StopWatchDAO.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/12.
//

import UIKit
import RealmSwift

class StopWatchDAO {
    private let realm = try! Realm()
    
    /// 특정 Date의 Object가 존재하는지 여부를 반환하는 메소드
    func doesObjectExist<T: Object>(type: T.Type, forDate: String) -> Bool {
        return self.realm.object(ofType: T.self, forPrimaryKey: forDate) == nil ? false : true
    }
    
    func getObject<T: Object>(_ type: T.Type) -> Results<T> {
        return self.realm.objects(T.self)
    }
    
    /// 오늘의 데이터가 없을 때 오늘 데이터를 생성하는 함수
    func createDailyData(_ forDate: String) {
        guard !self.doesObjectExist(type: DailyData.self, forDate: forDate) else { return }

        do {
            try realm.write {
                realm.add(DailyData(forDate))
            }
        } catch {
            print("Failed to create Object: \(error.localizedDescription)")
        }
    }
    
    /// date날짜 데이터 삭제
    func deleteDailyData(date: String) {
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
    
    /// 과목 추가 메소드
    func addSegment(_ colorRow: Int, name: String, forDate: String) {
        do {
            try realm.write {
                let segment = Segments(name: name, colorCode: colorRow)
                realm.add(segment)
                
                let dailyData = getObject(DailyData.self)
                
                for data in dailyData {
                    data.dailySegment.append(SegmentData(date: data.date, segment: segment))
                }
            }
        } catch {
            print("Failed to add segment: \(error.localizedDescription)")
        }
    }
    
//    func checkSegmentData(date: String) {
//        let segmentData = self.realm.objects(SegmentData.self).where {
//            $0.date == date
//        }
//        let segemnts = self.realm.objects(Segments.self)
//        guard let dailyData = self.realm.object(ofType: DailyData.self, forPrimaryKey: date) else { return }
//
//        for segment in segemnts {
//            let isSeg = segmentData.contains{ seg in seg.segment == segment }
//            if isSeg == false {
//                try! self.realm.write{
//                    let object = SegmentData() // 오늘 과목들 생성
//                    object.date = date
//                    object.goal = 0
//                    object.value = 0
//                    object.segment = segment
//                    realm.add(object)
//
//                    dailyData.dailySegment.append(object)
//                }
//            }
//        }
//    }
    
    //MARK: - DailyData 편집(읽기)
    /// DailyData 읽기
    func getDailyData(_ date: String) -> DailyData? {
        return self.realm.object(ofType: DailyData.self, forPrimaryKey: date)
    }
    
    /// 총 시간 읽기!
    func getTotalTime(_ date: DateComponents) -> TimeInterval {
        guard let data = self.realm.object(ofType: DailyData.self, forPrimaryKey: date.stringFormat) else { return 0 }
        
        return data.totalTime
    }
    
    ///총 목표 시간 읽기
    func getTotalGoalTime(_ date: DateComponents) -> TimeInterval {
        guard let data = self.realm.object(ofType: DailyData.self, forPrimaryKey: date.stringFormat) else { return 0 }
        
        return data.totalGoalTime
    }
    
    //MARK: - SegemntData 편집(읽기, 삭제)
    func getSegmentData(_ date: String, section: Int) -> SegmentData {
        let segment = realm.objects(SegmentData.self).where{ seg in
            seg.date == date
        }[section]
        return segment
    }
    
    func deleteSegmentData( row: Int) {
        let segment = self.realm.objects(Segments.self)[row]
        
        let filter = self.realm.objects(SegmentData.self).where{
            $0.segment == segment
        }
        
        try! self.realm.write {
            for data in filter {
                self.realm.delete(data)
            }
            self.realm.delete(segment)
        }
    }
    
    
    //MARK: - TodoList 편집 (이동, 복사, 수정, 삭제, 체크 이미지 변경)
    ///TodoList to에서 from으로 이동하기
    func moveTodoList(to: SegmentData, from: SegmentData, row: Int) -> Bool {
        let list = to.toDoList[row]
        do {
            try self.realm.write{
                to.toDoList.remove(at: row)
                to.listCheckImageIndex.remove(at: row)
                
                from.toDoList.append(list)
                from.listCheckImageIndex.append(0)
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    ///TodoList to에서 from 으로 복사하기
    func copyTodoList(to: SegmentData, from: SegmentData, row: Int) -> Bool {
        do {
            try self.realm.write{
                from.toDoList.append(to.toDoList[row])
                from.listCheckImageIndex.append(0)
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    /// TodoList 수정
    func editTodoList(_ segData: SegmentData, row: Int, text: String) {
        do {
            try self.realm.write {
                segData.toDoList[row] = text
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// TodoList 삭제
    func deleteTodoList(_ segData: SegmentData, row: Int) {
        do {
            try self.realm.write {
                segData.toDoList.remove(at: row) // 리스트 삭제
                segData.listCheckImageIndex.remove(at: row)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// TodoList 체크 이미지 변경
    func changeListCheckImage(_ segData: SegmentData, row : Int) {
        var index = segData.listCheckImageIndex[row]
        index += 1
        do {
            try self.realm.write{
                segData.listCheckImageIndex[row] = index % 4
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - 스톱워치 시간 추가
    func addTotalTime(_ timeInterval: TimeInterval, data: DailyData, row: Int) {
        do {
            try self.realm.write{
                data.dailySegment[row].value += timeInterval //선택한 과목에 시간 추가
                var totalTime: TimeInterval = 0
                for segValue in data.dailySegment {
                    totalTime += segValue.value
                }
                data.totalTime = totalTime
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Segment
    /// Segment 불러오기
    func getSegment(_ row: Int) -> Segments {
        return self.realm.objects(Segments.self)[row]
    }
}

