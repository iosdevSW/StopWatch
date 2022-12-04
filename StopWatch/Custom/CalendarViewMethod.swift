//
//  CalendarViewMethod.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/17.
//

import UIKit

class CalendarMethod {
    let todayDate = Calendar.current.date(from: DateComponents())
    var selectDate = Calendar.current.date(from: DateComponents())
    
    // 날짜 년,월,일로 쪼개서 반환
    func splitDate(date: String) -> (String,String,String) {
        let split = date.split(separator: ".")
        let year = String(split[0])
        let month = String(split[1])
        let day = String(split[2])
        
        return (year,month,day)
    }
    
    func splitDate(date: String) -> (Int,Int,Int) {
        let split = date.split(separator: ".")
        let year = Int(split[0]) ?? 0
        let month = Int(split[1]) ?? 0
        let day = Int(split[2]) ?? 0
        
        return (year,month,day)
    }
    
    // 달 바꾸는 메소드
    func changeMonth(tag: Int,date: String) -> (Int,Int,Int) {
        var year =  Int(self.splitDate(date: date).0)!
        var month = Int(self.splitDate(date: date).1)!
        var day = Int(self.splitDate(date: date).2)!
        
        switch tag {
        case 0: // previous button
            if month == 1 {
                year -= 1
                month = 12
            }else{
                month -= 1
            }
            break
        case 1: // next button
            if month == 12 {
                year += 1
                month = 1
            }else{
                month += 1
            }
            break
        default:
            return (year,month,day)
        }
        
        // 날짜 오류 방지
        let maxDay = self.getDaysOfMonth(year: year, month: month)
        if day > maxDay {
            day = maxDay
        }
        
        return (year,month,day)
    }
    
    func dateCalculation() {
        let cal = Calendar.current
        let firstDayOfMonth = cal.date(from: DateComponents())
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        let dayOfMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)!.count
    }
    
    //요일 변화 메소드
    func convertDate(date: String)-> String{
        var (year,month,_):(String,String,String) = CalendarMethod().splitDate(date: date)
        var monthWord = ""
        year.removeFirst()
        year.removeFirst()
        
        switch month {
        case "01": monthWord = "January"
        case "02": monthWord = "February"
        case "03": monthWord = "March"
        case "04": monthWord = "April"
        case "05": monthWord = "May"
        case "06": monthWord = "June"
        case "07": monthWord = "July"
        case "08": monthWord = "August"
        case "09": monthWord = "September"
        case "10": monthWord = "October"
        case "11": monthWord = "November"
        case "12": monthWord = "December"
        default:
            print("error")
        }
        
        return year + " " + monthWord
    }
    
    func isLeapYear(year: Int) -> Bool {
        if (year%4 == 0 && year%100 != 0) || year%400 == 0{
            return true //4로 떨어지고 100으로 안떨어지거나 400으로 떨어지면 윤년
        } else { return false } //아니면 평년
    }

    func getFirstDay(date: String) -> Int {
        let (year,month,_): (Int,Int,Int) = CalendarMethod().splitDate(date: date)
        let first = (year-1) / 400 // 400으로 떨어진건 무조건 윤년.
        let second = (year-1) / 100 - first //100으로 나눈 수는 평년 그러나 400으로 나눈건 윤년이니까 빼준다.
        let leapYear =  (year-1) / 4 - second // 4로 떨어진 수에 100으로 떨어진 수를 빼면 윤년
        var days = (year - 1) * 365 + leapYear + 1 // 1년 1월 1일 기준 월요일로 잡고 월요일값 1에 일 수 만큼 더한 후 7로 나누어 그 해 첫 요일 값을 구한다.
        // 월: 1, 화: 2, 수: 3, 목: 4, 금: 5, 토: 6, 일: 0
        var monthDay = 0
        
        for i in 1..<month {
            monthDay += self.getDaysOfMonth(year: year, month: i)
        }
        days += monthDay

        return days % 7
    }

    // 월마다 일 수 구하기.
    func getDaysOfMonth(year: Int, month: Int) -> Int {
        switch month {
        case 4 : fallthrough
        case 6 : fallthrough
        case 9 : fallthrough
        case 11 : return 30
        case 2 :
            if isLeapYear(year: year) {
                return 29
            }else { return 28 }
            
        default:
            return 31
        }
    }
    
    // 날짜 인덱스 구하는 함수.
    func returnIndexOfDay(date: String) -> Int{
        let dayNumber = self.getFirstDay(date: date)
        let day: Int = self.splitDate(date: date).2
        
        return day + dayNumber
    }
}
