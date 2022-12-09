//
//  TodoListHeaderView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/15.
//

import UIKit

class TodoListHeaderView: UIView {
    //레이블 길이에 따라 동적 크기 할당
    let frameView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.layer.shadowOpacity = 0.4
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.backgroundColor = .white
        
        return view
    }()

    let plusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "plus.square.on.square")
        view.tintColor = .white
        
        return view
    }()
    
    let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        
        return label
    }()
    
    let touchViewButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubView()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: addsubView
    func addSubView(){
        self.addSubview(self.frameView)
        
        self.frameView.addSubview(self.categoryNameLabel)
        self.frameView.addSubview(self.plusImageView)
        self.frameView.addSubview(self.touchViewButton)
    }
    
    //MARK: layout
    func layout(){
        NSLayoutConstraint.activate([
            self.frameView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 4),
            self.frameView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
//            self.frameView.widthAnchor.constraint(equalToConstant: 80),
            self.frameView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            self.categoryNameLabel.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor, constant: 10),
            
            self.categoryNameLabel.centerYAnchor.constraint(equalTo: self.frameView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.plusImageView.centerYAnchor.constraint(equalTo: self.frameView.centerYAnchor),
            self.plusImageView.leadingAnchor.constraint(equalTo: self.categoryNameLabel.trailingAnchor, constant: 6),
            self.plusImageView.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor, constant: -10),
            self.plusImageView.widthAnchor.constraint(equalToConstant: 16),
            self.plusImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        NSLayoutConstraint.activate([
            self.touchViewButton.leadingAnchor.constraint(equalTo: self.frameView.leadingAnchor),
            self.touchViewButton.trailingAnchor.constraint(equalTo: self.frameView.trailingAnchor),
            self.touchViewButton.topAnchor.constraint(equalTo: self.frameView.topAnchor),
            self.touchViewButton.bottomAnchor.constraint(equalTo: self.frameView.bottomAnchor)
        ])
    }
}
