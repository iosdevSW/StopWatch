//
//  EditTodoListView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/14.
//

import UIKit

class EditTodoListView: UIView{
    var indexPath: IndexPath? // 선택한 리스트의 IndexPath를 받아올 프로퍼티
    let buttonSize: CGFloat = 60
    
    let buttonContainerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var editButton: CustomListEditView = { // 수정 버튼
       let view = CustomListEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.setImage(UIImage(systemName: "pencil"), for: .normal)
        view.label.text = "수 정"
        view.button.tag = 0
        
        return view
    }()
    
    lazy var deleteButton: CustomListEditView = { // 삭제 버튼
        let view = CustomListEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.setImage(UIImage(systemName: "trash"), for: .normal)
        view.label.text = "삭 제"
        view.button.tag = 1
        
        return view
    }()
    
    lazy var changeCheckImageButton: CustomListEditView = { // todolist 체크이미지 변경 버튼
        let view = CustomListEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.setImage(UIImage(systemName: "rectangle.2.swap" ), for: .normal)
        view.label.text = "모양 변경"
        view.button.tag = 2
        
        return view
    }()
    
    lazy var changeDateButton: CustomListEditView = { // todolist 날짜,과목 변경 버튼
        let view = CustomListEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.setImage(UIImage(systemName: "calendar" ), for: .normal)
        view.label.text = "날짜 변경"
        view.button.tag = 3
        
        return view
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.alpha = 0.94
        self.layer.cornerRadius = 14
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.darkGray.cgColor
        
        self.addSubview(self.buttonContainerStackView)
        self.addSubview(self.title)
        self.buttonContainerStackView.addSubview(self.editButton)
        self.buttonContainerStackView.addSubview(self.deleteButton)
        self.buttonContainerStackView.addSubview(self.changeCheckImageButton)
        self.buttonContainerStackView.addSubview(self.changeDateButton)
        self.addTarget()
        self.layout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    
    //MARK: - addTarget
    func addTarget() {
    }
    
    
    //MARK: - layout
    func layout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.title.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.editButton.leadingAnchor.constraint(equalTo: self.buttonContainerStackView.leadingAnchor),
            self.editButton.widthAnchor.constraint(equalToConstant: self.buttonSize),
            self.editButton.heightAnchor.constraint(equalToConstant: self.buttonSize),
            self.editButton.topAnchor.constraint(equalTo: self.buttonContainerStackView.topAnchor, constant: 8),
            self.editButton.bottomAnchor.constraint(equalTo: self.buttonContainerStackView.bottomAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            self.deleteButton.leadingAnchor.constraint(equalTo: self.editButton.trailingAnchor,constant: 10),
            self.deleteButton.topAnchor.constraint(equalTo: self.buttonContainerStackView.topAnchor, constant: 8),
            self.deleteButton.heightAnchor.constraint(equalToConstant: self.buttonSize),
            self.deleteButton.widthAnchor.constraint(equalToConstant: self.buttonSize),
            self.deleteButton.bottomAnchor.constraint(equalTo: self.buttonContainerStackView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.changeDateButton.topAnchor.constraint(equalTo: self.buttonContainerStackView.topAnchor, constant: 8),
            self.changeDateButton.heightAnchor.constraint(equalToConstant: self.buttonSize),
            self.changeDateButton.widthAnchor.constraint(equalToConstant: self.buttonSize),
            self.changeDateButton.leadingAnchor.constraint(equalTo: self.deleteButton.trailingAnchor, constant: 10),
            self.changeDateButton.bottomAnchor.constraint(equalTo: self.buttonContainerStackView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.changeCheckImageButton.topAnchor.constraint(equalTo: self.buttonContainerStackView.topAnchor, constant: 8),
            self.changeCheckImageButton.heightAnchor.constraint(equalToConstant: self.buttonSize),
            self.changeCheckImageButton.widthAnchor.constraint(equalToConstant: self.buttonSize),
            self.changeCheckImageButton.bottomAnchor.constraint(equalTo: self.buttonContainerStackView.bottomAnchor),
            self.changeCheckImageButton.leadingAnchor.constraint(equalTo: self.changeDateButton.trailingAnchor, constant: 10),
            self.changeCheckImageButton.trailingAnchor.constraint(equalTo: self.buttonContainerStackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
//            self.buttonContainerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.buttonContainerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.buttonContainerStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.buttonContainerStackView.topAnchor.constraint(equalTo: self.title.bottomAnchor),
            self.buttonContainerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    
}
