//
//  EditTodoListView.swift
//  StopWatch
//
//  Created by 신상우 on 2021/12/14.
//

import UIKit
import Then
import SnapKit

final class EditTodoListView: UIView {
    let (section, row): (Int,Int) // 선택한 리스트의 IndexPath를 받아올 프로퍼티
    
    lazy var buttonStackView = UIStackView(arrangedSubviews: [editButton,deleteButton,changeDateButton,changeCheckImageButton]).then {
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    let title = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .light)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let editButton = ListEditItemView().then { // 수정 버튼
        $0.button.setImage(UIImage(systemName: "pencil"), for: .normal)
        $0.label.text = "수 정"
        $0.button.tag = 0
    }
    
    private let deleteButton = ListEditItemView().then { // 삭제 버튼
        $0.button.setImage(UIImage(systemName: "trash"), for: .normal)
        $0.label.text = "삭 제"
        $0.button.tag = 1
    }
    
    private let changeCheckImageButton = ListEditItemView().then { // todolist 체크이미지 변경 버튼
        $0.button.setImage(UIImage(systemName: "rectangle.2.swap" ), for: .normal)
        $0.label.text = "모양 변경"
        $0.button.tag = 2
    }
    
    private let changeDateButton = ListEditItemView().then { // todolist 날짜,과목 변경 버튼
        $0.button.setImage(UIImage(systemName: "calendar" ), for: .normal)
        $0.label.text = "날짜 변경"
        $0.button.tag = 3
    }
    
    //MARK: - Init
    init(_ indexPath: IndexPath) {
        self.section = indexPath.section
        self.row = indexPath.row
        
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.alpha = 0.94
        self.layer.cornerRadius = 14
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.darkGray.cgColor
        
        self.addSubview(self.buttonStackView)
        self.addSubview(self.title)
    
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - layout
    private func layout() {
        self.title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
        }
        
        self.buttonStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-4)
            $0.top.equalTo(self.title.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
        }
    }
}
