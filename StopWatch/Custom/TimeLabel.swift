//
//  TimeLabelView.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/11/27.
//

import UIKit

enum TimeLabelType {
    /// 시 분 초 밀리초
    case hmss
    /// 시 분 초
    case hms
    /// 시 분
    case hm
}

final class TimeLabel: UILabel {
    //MARK: - Properties
    private var labelType: TimeLabelType = .hms
    
    //MARK: - Init
    init(_ type: TimeLabelType) {
        super.init(frame: .zero)
        self.labelType = type
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    func configure() {
        self.text = "00 : 00 : 00"
        self.textAlignment = .center
        self.textColor = .darkGray
    }
    
    //MARK: - updateTime
    func updateTime(_ time: (String,String,String,String) ) {
        let (ms,s,m,h) = time
        switch self.labelType {
        case .hmss:
            let text = "\(h) : \(m) : \(s) \(ms)"
            let attribute = NSMutableAttributedString(string: text)
            attribute.addAttribute(.font,
                                   value: UIFont.systemFont(ofSize: 14, weight: .regular),
                                   range: .init(location: text.count-2, length: 2))
            self.attributedText = attribute
        case .hms:
            let text = "\(h) : \(m) : \(s)"
            self.text = text
        case .hm:
            let text = "\(h) : \(m)"
            self.text = text
        }
    }
}
