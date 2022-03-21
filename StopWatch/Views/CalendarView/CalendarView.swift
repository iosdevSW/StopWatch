//
//  CalendarView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/17.
//

import UIKit
import RealmSwift

class CalendarView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var calendarInfo: CalendarViewInfo = CalendarViewInfo()
    let calendarMethod = CalendarMethod()
    let dayArray = ["S","M","T","W","T","F","S"]
    var saveDate = ""
    
    var delegate: StopWatchViewController?
    var calendarMode: CalendarMode = .week {
        didSet{
            switch calendarMode {
            case .week:
                if let layout =  self.calendarView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                }
            case .month:
                if let layout =  self.calendarView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                }
            }
        }
    }
    
    let collectionHeaderView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .white
        
        return view
    }()
    
    let calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
//        view.register(CalendarMonthCell.self, forCellWithReuseIdentifier: "monthCell")
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true // 페이징 스크롤 처리
        // calendar week of month 참고!!
        
        return view
    }()
    
    let underLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.alpha = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.modelingInit()
        self.addSubView()
        self.layout()
        self.collectionHeaderView.delegate = self
        self.collectionHeaderView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    func modelingInit(){
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width - 20 //화면 너비
        
        self.calendarInfo.cellSize = width / 7
        self.calendarInfo.heightNumberOfCell = 6
    }
    
//    func getToday(){
//        let today = Date()
//        var calendar = Calendar.current
//        calendar.timeZone = .current
//        self.year = calendar.component(.year, from: today)
//        self.month = calendar.component(.month, from: today)
//        self.day = calendar.component(.day, from: today)
//    }
    
    // 전체 셀 개수 구하기.
    func getNumberOfCell() -> Int{
        let (year,month,_): (Int,Int,Int) = self.calendarMethod.splitDate(date: self.saveDate)
        let startDay = self.calendarMethod.getFirstDay(date: self.saveDate)
        let dayCount = self.calendarMethod.getMonthDay(year: year, month: month)
        
        if startDay + dayCount <= self.calendarInfo.numberOfItem{
            self.calendarInfo.heightNumberOfCell = 6
        }else {
            self.calendarInfo.heightNumberOfCell = 7
        }

        return self.calendarInfo.numberOfItem
        
    }
    
    //월마다 일 수 계산하여 날짜 표시하는 함수
    func presentCalendar(row: Int, cell: UICollectionViewCell){
        let cell = cell as! CalendarCell
        // 셀 배경 초기화
        cell.frameView.backgroundColor = .white
        cell.dataCheckView.isHidden = true
        
        let (year,month,day): (Int,Int,Int) = self.calendarMethod.splitDate(date: self.saveDate)
        let dayNumber = self.calendarMethod.getFirstDay(date: self.saveDate)
        let index = dayNumber + day
        
        // 해당 달의 첫 날짜(1일)에 해당하는 요일에 맞춰 달력 나타내기.
        if row >= dayNumber{
            if row >= self.calendarMethod.getMonthDay(year: year, month: month) + dayNumber{
                cell.isUserInteractionEnabled = false
                cell.dateLabel.text = " " // 초과
                cell.dataCheckView.isHidden = true
            }else{
                cell.dateLabel.text = "\(row + 1 - dayNumber)"
                // 데이터 있는 날짜 표시
                let realm = try! Realm()
                
                let date = String(year) + "." + self.returnString(month) + "." + self.returnString(row + 1  - dayNumber)
                if let _ = realm.object(ofType: DailyData.self, forPrimaryKey: date) {
                    cell.dataCheckView.isHidden = false
                }
                //선택된 셀 배경 바꾸기
                if index == (row + 1) {
                    cell.frameView.backgroundColor = .standardColor
                }
            }
        }else {
            cell.dateLabel.text = " "  // 미만
            cell.dataCheckView.isHidden = true
            cell.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - setGesture
    
    //MARK: Selector
    
    //MARK: addsubview
    func addSubView(){
        self.addSubview(self.collectionHeaderView)
        self.addSubview(self.calendarView)
        self.addSubview(self.underLineView)
    }
    //MARK: addtarget
    
    //MARK: layout
    func layout(){
        NSLayoutConstraint.activate([
            self.collectionHeaderView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionHeaderView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            self.calendarView.topAnchor.constraint(equalTo: self.collectionHeaderView.bottomAnchor),
            self.calendarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.calendarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.calendarView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.underLineView.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor, constant: 4),
            self.underLineView.leadingAnchor.constraint(equalTo: self.calendarView.leadingAnchor, constant: 14),
            self.underLineView.trailingAnchor.constraint(equalTo: self.calendarView.trailingAnchor, constant: -14),
            self.underLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    //MARK: - CollectionView Delegate,DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionHeaderView {
            return self.dayArray.count
        } else {
            return self.getNumberOfCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath) as! CalendarCell
        
        if collectionView == self.collectionHeaderView  {
            cell.isUserInteractionEnabled = false
            cell.dateLabel.textColor = .darkGray
            cell.dateLabel.text = self.dayArray[indexPath.row]
            cell.dataCheckView.isHidden = true
            
            if indexPath.row == 0 { cell.dateLabel.textColor = .red }
            if indexPath.row == 6 { cell.dateLabel.textColor = .blue }
        } else {
            cell.isUserInteractionEnabled = true
            cell.dataCheckView.isHidden = false
            self.presentCalendar(row: indexPath.row, cell: cell)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 선택한 인덱스 날짜 계산
        if collectionView == self.calendarView {
            let row = indexPath.row
            let dayNumber = self.calendarMethod.getFirstDay(date: self.saveDate)
            
            let day = self.returnString(row + 1 - dayNumber)
            let year: String = CalendarMethod().splitDate(date: self.saveDate).0
            let month: String = CalendarMethod().splitDate(date: self.saveDate).1
            
            let string = "\(year).\(month).\(day)"
            
            self.saveDate = string
            self.calendarView.reloadData()
            self.delegate?.clickDay(saveDate: string)
        }
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    //뷰 크기 리턴
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {    
            return CGSize(
                width: self.calendarInfo.cellSize!,
                height: 32
                )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

