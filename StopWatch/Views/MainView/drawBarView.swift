//
//  drawBarView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/05/17.
//

import UIKit
import SnapKit
import Then

final class DrawBarView: UIView {
    //MARK: - Properties
    var per: Float = 0 {
        didSet {
            self.showPersent()
        }
    }
    
    private let persentLabel = UILabel().then {
        $0.text = "0%"
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private let progressView = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = .systemGray4
        $0.progress = 0.0
        
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.progressViewStyle = .default
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layOut()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    private func showPersent(){
        let text = per <= 1 ? "\(String(format:"%.2f",per * 100))%" : "100%"
        self.persentLabel.text = text
        self.progressView.setProgress(self.per, animated: true)
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.progressView)
        self.progressView.addSubview(self.persentLabel)
    }
    
    //MARK: - Layout
    private func layOut(){
        self.progressView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(35)
        }
        
        self.persentLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
