//
//  TodoListCell.swift
//  StopWatch
//
//  Created by 신상우 on 2021/09/16.
//

import UIKit
import RealmSwift

class TodoListCell: UITableViewCell {
    var cellNumber = 0
    let realm = try! Realm()
    
    var saveDate = ""
//    let frameView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        return view
//    }()
    let listLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        
        return label
    }()
    
    let getListTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 16, weight: .light)
        tf.textColor = .black
        tf.underLine.backgroundColor = .black

        return tf
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let checkImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .darkGray
    
        return view
    }()
    
    let changeImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.addSubView()
        self.layout()
        self.addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubView(){
//        self.addSubview(self.frameView)
        self.contentView.addSubview(self.listLabel)
        self.contentView.addSubview(self.getListTextField)
        self.contentView.addSubview(self.checkImageView)
        self.contentView.addSubview(self.changeImageButton)
        self.checkImageView.addSubview(self.lineView)
        
    }
    
    func layout(){
//        NSLayoutConstraint.activate([
//            self.frameView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.frameView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            self.frameView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.frameView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
        
        NSLayoutConstraint.activate([
            self.listLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:  20),
            self.listLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.listLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.listLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            self.getListTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            self.getListTextField.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.getListTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.getListTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            self.checkImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor,constant: -4),
            self.checkImageView.widthAnchor.constraint(equalToConstant: 18),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        NSLayoutConstraint.activate([
            self.lineView.bottomAnchor.constraint(equalTo: self.checkImageView.bottomAnchor),
            self.lineView.leadingAnchor.constraint(equalTo: self.checkImageView.leadingAnchor,constant: -2),
            self.lineView.trailingAnchor.constraint(equalTo: self.checkImageView.trailingAnchor,constant: 2),
            self.lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            self.changeImageButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.changeImageButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -4),
            self.changeImageButton.widthAnchor.constraint(equalToConstant: 18),
            self.changeImageButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    //MARK: addTarget
    func addTarget(){
        self.changeImageButton.addTarget(self, action: #selector(self.changeImage(_:)), for: .touchUpInside)
    }
    
    //MARK: Selector
    @objc func changeImage(_ sender: UIButton){
        let row = sender.tag
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment
        
        guard let section = sender.superview?.tag else { return }
        guard let todoListTableView = sender.superview?.superview?.superview as? UITableView else { return }

        var index = segment[section].listCheckImageIndex[row]
        index += 1
        try! self.realm.write{
            segment[section].listCheckImageIndex[row] = index % 4
        }
        
        todoListTableView.reloadData()
    }
}
