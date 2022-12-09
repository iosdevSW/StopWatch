//
//  TodoListCell.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/16.
//

import UIKit
import RealmSwift
import SnapKit
import Then

final class TodoListCell: UITableViewCell {
    private let realm = try! Realm()
    
    var saveDate = ""

    let listLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .black
    }
    
    let getListTextField = CustomTextField().then {
        $0.font = .systemFont(ofSize: 16, weight: .light)
        $0.textColor = .black
        $0.underLine.backgroundColor = .black
    }

    let checkImageView = UIImageView().then {
        $0.layer.cornerRadius = 4
        $0.contentMode = .center
        $0.tintColor = .darkGray
    }
    
    let lineView = UIView()
    let changeImageButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        self.addSubView()
        self.layout()
        self.addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView(){
        self.contentView.addSubview(self.listLabel)
        self.contentView.addSubview(self.getListTextField)
        self.contentView.addSubview(self.checkImageView)
        self.contentView.addSubview(self.changeImageButton)
        self.checkImageView.addSubview(self.lineView)
    }
    
    private func layout() {
        self.listLabel.snp.makeConstraints {
            $0.leading.equalTo(self.contentView.snp.leading).offset(20)
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            $0.top.equalTo(self.contentView.snp.top)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-4)
        }
        
        self.getListTextField.snp.makeConstraints {
            $0.leading.equalTo(self.contentView.snp.leading).offset(20)
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            $0.top.equalTo(self.contentView.snp.top)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-4)
        }
        
        self.checkImageView.snp.makeConstraints {
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(-4)
            $0.width.equalTo(18)
            $0.height.equalTo(22)
        }
        
        self.lineView.snp.makeConstraints {
            $0.bottom.equalTo(self.checkImageView.snp.bottom)
            $0.leading.equalTo(self.checkImageView.snp.leading).offset(-2)
            $0.trailing.equalTo(self.checkImageView.snp.trailing).offset(2)
            $0.height.equalTo(1)
        }
        
        self.changeImageButton.snp.makeConstraints {
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(-4)
            $0.width.equalTo(18)
            $0.height.equalTo(22)
        }
    }
    
    //MARK: addTarget
    private func addTarget(){
        self.changeImageButton.addTarget(self, action: #selector(self.didClickChangeImageButton(_:)), for: .touchUpInside)
    }
    
    //MARK: Selector
    @objc private func didClickChangeImageButton(_ sender: UIButton){
        let row = sender.tag
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment
        
        guard let section = sender.superview?.tag else { return }

        var index = segment[section].listCheckImageIndex[row]
        index += 1
        try! self.realm.write{
            segment[section].listCheckImageIndex[row] = index % 4
        }
        
        NotificationCenter.default.post(name: .changeSaveDate, object: nil)
    }
}
