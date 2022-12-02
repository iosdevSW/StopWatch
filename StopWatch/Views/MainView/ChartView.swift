//
//  ChartView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/11.
//

import UIKit
import RealmSwift
import SnapKit

final class ChartView: UIView {
    //MARK: properties
    var saveDate = ""
    var total: TimeInterval = 0.0
    lazy var radius = min(self.frame.width, self.frame.height) * 0.40
    private let realm = try! Realm()
    
    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.compact.down")
        $0.tintColor = .darkGray
    }
    
    private let closeLabel = UILabel().then {
        $0.text = "닫기"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .systemGray4
        $0.textAlignment = .center
    }
    
    private let guideLabel = UILabel().then {
        $0.text = "측정된 시간이 없습니다."
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .systemGray3
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var textAttributes : [NSAttributedString.Key : Any] = {
        return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubview(self.guideLabel)
        self.addSubview(self.closeLabel)
        self.addSubview(self.chevronImageView)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///주<->월 달력 전환시 constant 변경
    func updateConstant(_ constant: Int) {
        self.closeLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(constant)
        }
    }
    
    // 날짜형식 문자열 리턴
    func date() -> String{
        let date = DateFormatter()
        date.locale = Locale(identifier: Locale.current.identifier)
        date.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        date.dateFormat = "YYYY.MM.dd"
        
        return date.string(from: Date())
    }
    
    //MARK: - Layout
    private func layout() {
        self.closeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        self.chevronImageView.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.closeLabel.snp.bottom)
        }
        
        self.guideLabel.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
    
    //MARK: Draw
    override func draw(_ rect: CGRect) {
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        self.guideLabel.isHidden = true
        guard let segment = filter?.dailySegment else {
            self.guideLabel.isHidden = false
            return
        }
        self.total = segment.reduce(0){
            (result,segment) in
            return segment.value + result
        }
        
        if total == 0 {
            self.guideLabel.isHidden = false
            return
        }
            
            let center = CGPoint(x: rect.midX, y: rect.midY)
            var endAngle: CGFloat = 0.0
            var startAngle: CGFloat = ((-.pi) / 2)
            
            segment.forEach(){(segment) in //각 카테고리별로 그래프 그리기!
                let colorCode = segment.segment!.colorCode
                let color = uiColorFromHexCode(colorCode)
                
                let ratioTime = CGFloat(segment.value / self.total)
                endAngle = startAngle + (ratioTime * (.pi * 2))
               
                let path = UIBezierPath()
                path.move(to: center)
                path.addArc(withCenter: center, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
                color.setFill()
                path.fill()
                // divide line stroke
                UIColor.white.setStroke()
                path.lineWidth = 2
                path.close()
                path.stroke()
                
                if ratioTime > 0.09 { // 전체의 9%이상이면 Label표시
                    // 카테고리 센터 각도 구하기(label표시 위치)
                    let halfAngle = startAngle + (endAngle - startAngle) * 0.5
                    // the ratio of how far away from the center of the pie chart the text will appear
                    let textPositionValue : CGFloat = 0.65
                    let segmentCenter = CGPoint(x: center.x + radius * textPositionValue * cos(halfAngle), y: center.y + radius * textPositionValue * sin(halfAngle))
                
                    // 카테고리 이름 및 시간 가져오기
                    let name: NSString = segment.segment!.name as NSString
                    let (_,_,minute,hour) = self.divideSecond(timeInterval: segment.value )
                    let timeString: NSString = "\(hour) : \(minute)" as NSString
                
                    //set textRender size 설정
                    var renderRect = CGRect(origin: .zero, size: name.size(withAttributes: self.textAttributes))
                    var renderTimeRect = CGRect(origin: .zero, size: timeString.size(withAttributes: self.textAttributes))
                    
                    //카테고리 색의 RGB평균을 구하여 0.7보다 크면 검은색, 작으면 흰색 글씨로 표시
                    if let RGB = color.cgColor.components {
                        var averageRGB: CGFloat = 0
                        
                        if color.cgColor.numberOfComponents == 2{
                            averageRGB = RGB[0]
                        }else{
                            averageRGB = (RGB[0] + RGB[1] + RGB [2]) / 3
                        }
                        self.textAttributes[NSAttributedString.Key.foregroundColor] = (averageRGB > 0.7) ? UIColor.black : UIColor.white
                    }
                    
                    // center the origin of the rect
                    renderRect.origin = CGPoint(x: segmentCenter.x - renderRect.size.width * 0.5, y: segmentCenter.y - renderRect.size.height * 0.5)
                
                    renderTimeRect.origin = CGPoint(x: segmentCenter.x - renderTimeRect.size.width * 0.5, y: segmentCenter.y - renderRect.size.height * -0.5)
                
                    // text(name,time) draw
                    name.draw(in: renderRect, withAttributes: self.textAttributes)
                    timeString.draw(in: renderTimeRect, withAttributes: self.textAttributes)
                }
                startAngle = endAngle
            }
    }
}
