//
//  GuideLabelView.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/27.
//

import UIKit

class GuideLabelView: UIView {
    //MARK: - Properties
    let rotateImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        view.tintColor = .systemGray2
        
        return view
    }()
    
    let rotateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "타이머를 시작하려면 핸드폰을 뒤집어주세요."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray2
        
        
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addsubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - addsubView
    func addsubView(){
        self.addSubview(self.rotateImage)
        self.addSubview(self.rotateLabel)
    }
    
    //MARK: - layout
    func layout(){
        NSLayoutConstraint.activate([
            self.rotateImage.trailingAnchor.constraint(equalTo: self.rotateLabel.leadingAnchor, constant: -10),
            self.rotateImage.widthAnchor.constraint(equalToConstant: 20),
            self.rotateImage.heightAnchor.constraint(equalToConstant: 18),
            self.rotateImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.rotateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            self.rotateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
