//
//  CalendarView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/17.
//

import UIKit
import RealmSwift
import Then
import SnapKit

class CalendarView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    //MARK: - Properties
    let dayArray = ["S","M","T","W","T","F","S"]
    var saveDate = "" // 저장할 날짜를 위한 문자열
    var presentDate = "" {// 달력을 표시하기 위한 날짜 문자열
        didSet{
            self.calendarView.reloadData()
        }
    }
    
    var calendarInfo: CalendarViewInfo = CalendarViewInfo()
    let calendarMethod = CalendarMethod()
    
    var saveDateDelegate: SaveDateDetectionDelegate?
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
    
    let yearMonthLabel = UILabel().then {
        $0.font = UIFont(name: "GodoM", size: 24)
        $0.text = "22 December"
        $0.backgroundColor = .white
    }
    
    private let previousMonthButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = .darkGray
        $0.tag = 0
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    private let nextMonthButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        $0.tintColor = .darkGray
        $0.tag = 1
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
    }
    
    let changeCalendarMode = UIButton(type: .system).then {
        $0.setTitle("주▾", for: .normal)
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
        $0.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    let collectionHeaderView = UICollectionView(frame: .zero,
                                                collectionViewLayout: UICollectionViewFlowLayout()).then {
        
        $0.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        $0.backgroundColor = .white
        $0.isScrollEnabled = false
    }
    
    let calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout().then { $0.scrollDirection = .horizontal }
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
            $0.backgroundColor = .white
            $0.showsHorizontalScrollIndicator = false
            $0.isPagingEnabled = true // 페이징 스크롤 처리
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.modelingInit()
        self.addSubView()
        self.layout()
        self.addTarget()
        
        self.collectionHeaderView.delegate = self
        self.collectionHeaderView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).saveDate
        self.presentDate =  (UIApplication.shared.delegate as! AppDelegate).saveDate
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
    
    // 전체 셀 개수 구하기.
    func getNumberOfCell() -> Int{
        let (year,month,_): (Int,Int,Int) = self.calendarMethod.splitDate(date: self.presentDate)
        let startDay = self.calendarMethod.getFirstDay(date: self.presentDate)
        let dayCount = self.calendarMethod.getDaysOfMonth(year: year, month: month)
        
        if startDay + dayCount < 35 { // 7개 요일 * 5 넘는 인덱스면 높이 7로 늘려서 반환
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
        cell.dateLabel.textColor = .darkGray
        
        let (year,month,_): (Int,Int,Int) = self.calendarMethod.splitDate(date: self.presentDate)
        let (saveYear,saveMonth,saveDay): (Int,Int,Int) = self.calendarMethod.splitDate(date: self.saveDate)
        let dayNumber = self.calendarMethod.getFirstDay(date: self.presentDate)
        let index = dayNumber + saveDay
        
        // 해당 달의 첫 날짜(1일)에 해당하는 요일에 맞춰 달력 나타내기.
        if row >= dayNumber{
            if row >= self.calendarMethod.getDaysOfMonth(year: year, month: month) + dayNumber{
                cell.isUserInteractionEnabled = false
                cell.dateLabel.text = "\(row - dayNumber - self.calendarMethod.getDaysOfMonth(year: year, month: month)+1)" // 초과
                cell.dateLabel.textColor = .lightGray
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
                if (saveYear == year) && (saveMonth == month) {
                    if index == (row + 1) {
                        cell.frameView.backgroundColor = .standardColor
                    }
                }
            }
        }else {
            cell.dateLabel.text = " "  // 미만
            cell.dataCheckView.isHidden = true
            cell.isUserInteractionEnabled = false
        }
    }
    
    
    //MARK: - Selector
    @objc func didClickChangeCalendarMode(_ sender: UIButton) {
        NotificationCenter.default.post(name: .changeCalendarMode, object: nil)
    }
    
    @objc func respondToButton(_ button:UIButton){
        let (year,month,day) = CalendarMethod().changeMonth(tag: button.tag, date: self.presentDate)
        
        self.presentDate = String(year) + "." + self.returnString(month) + "." + self.returnString(day)
        
        self.calendarView.reloadData()
        self.yearMonthLabel.text = CalendarMethod().convertDate(date: self.presentDate) // 타이틀 날짜 다시표시
        self.saveDateDelegate?.detectSaveDate(date: self.saveDate)
    }
    
    //MARK: - addsubview
    private func addSubView(){
        self.addSubview(self.yearMonthLabel)
        self.addSubview(self.previousMonthButton)
        self.addSubview(self.nextMonthButton)
        self.addSubview(self.changeCalendarMode)
        self.addSubview(self.collectionHeaderView)
        self.addSubview(self.calendarView)
    }
    
    //MARK: - layout
    private func layout(){
        self.yearMonthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        self.previousMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.yearMonthLabel.snp.trailing).offset(10)
            make.height.width.equalTo(28)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
        }
        
        self.nextMonthButton.snp.makeConstraints { make in
            make.leading.equalTo(self.previousMonthButton.snp.trailing).offset(4)
            make.height.width.equalTo(28)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
        }
        
        self.changeCalendarMode.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-30)
            make.centerY.equalTo(self.yearMonthLabel.snp.centerY)
            make.height.equalTo(28)
            make.width.equalTo(34)
        }
        
        self.collectionHeaderView.snp.makeConstraints { make in
            make.top.equalTo(self.yearMonthLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(32)
        }
        
        self.calendarView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(self.collectionHeaderView.snp.bottom)
        }
    }
    
    //MARK: - AddTarget
    private func addTarget() {
        self.changeCalendarMode.addTarget(self, action: #selector(self.didClickChangeCalendarMode(_:)), for: .touchUpInside)
        self.nextMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
        self.previousMonthButton.addTarget(self, action: #selector(self.respondToButton(_:)), for: .touchUpInside)
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
            let dayNumber = self.calendarMethod.getFirstDay(date: self.presentDate)
            
            let day = self.returnString(row + 1 - dayNumber)
            let year: String = CalendarMethod().splitDate(date: self.presentDate).0
            let month: String = CalendarMethod().splitDate(date: self.presentDate).1
            
            let string = "\(year).\(month).\(day)"
            
            self.saveDate = string
            self.presentDate = string
            self.calendarView.reloadData()
            self.delegate?.clickDay(saveDate: string)
            self.saveDateDelegate?.detectSaveDate(date: string)
            print(self.presentDate)
            print(self.saveDate)
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

