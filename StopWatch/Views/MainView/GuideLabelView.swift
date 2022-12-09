//
//  GuideLabelView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/27.
//

import UIKit

final class GuideLabelView: UIView {
    //MARK: - Properties
    private let rotateImage = UIImageView().then {
        $0.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        $0.tintColor = .systemGray2
    }
    
    private var timer: Timer?
    
    private let rotateLabel = UILabel().then {
        $0.text = "타이머를 시작하려면 핸드폰을 뒤집어주세요."
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .systemGray2
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addsubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    /// 애니메이션 시작
    func startAnimate() {
        self.isHidden = false
        var count = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) {
            count += 1
            UIView.transition(with: self,
                              duration: 3.0,
                              options: [.transitionFlipFromTop],
                              animations: nil)
            if count == 4 {
                $0.invalidate()
                self.stopAnimate()
            }
        }
    }
    
    /// 애니메이션 중단
    func stopAnimate() {
        self.layer.removeAllAnimations()
        self.timer?.invalidate()
        self.isHidden = true
    }
    
    //MARK: - addsubView
    private func addsubView(){
        self.addSubview(self.rotateImage)
        self.addSubview(self.rotateLabel)
    }
    
    //MARK: - layout
    private func layout(){
        self.rotateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        
        self.rotateImage.snp.makeConstraints { make in
            make.trailing.equalTo(self.rotateLabel.snp.leading).offset(-10)
            make.width.height.equalTo(18)
            make.centerY.equalToSuperview()
        }
    }
}
