//
//  MenuViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit
import Then
import SnapKit
import FirebaseAuth

final class MenuViewController: UIViewController {
    //MARK: - Properties
    weak var delegate: StopWatchVCDelegate?
    
    private let menuTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .standardColor
        $0.layer.borderColor = UIColor.standardColor.cgColor
        $0.layer.borderWidth = 1
        $0.register(MenuOptionCell.self, forCellReuseIdentifier: "MenuOptionCell")
    }
    
    private let emailTitleLabel = UILabel().then {
        $0.text = "로그인 정보"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .darkGray
    }
    
    private let emailLabel = UILabel().then {
        $0.text = "None"
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .lightGray
        $0.textAlignment = .left
    }
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .standardColor
        self.addSubView()
        self.layout()
        self.addNotification()
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        NotificationCenter.default.post(name: .changeAuthState, object: nil)
    }
    
    //MARK: - NotificationCenter
    private func addNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateEmailLabel), name: .changeAuthState, object: nil)
    }
    
    //MARK: - Selector
    @objc private func updateEmailLabel() {
        if let user = Auth.auth().currentUser,
           let email = user.email {
            self.emailLabel.text = email
        } else {
            self.emailLabel.text = "None"
        }
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.view.addSubview(self.menuTableView)
        self.view.addSubview(self.emailTitleLabel)
        self.view.addSubview(self.emailLabel)
    }
    
    //MARK: - Layout
    private func layout() {
        self.menuTableView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(160)
        }
        
        self.emailLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-50)
            $0.width.equalTo(160)
        }
        
        self.emailTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.emailLabel.snp.leading)
            $0.bottom.equalTo(self.emailLabel.snp.top)
        }
    }
}

extension MenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuOptionCell", for: indexPath) as! MenuOptionCell
        let menuOption = MenuOption(rawValue: indexPath.row)
        let isLogoutCell = indexPath.row == 4
        cell.configureCell(menuOption, isLogoutCell: isLogoutCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.handleMenuToggle(menuOption: MenuOption(rawValue: indexPath.row))
    }
        
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .systemGray4
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .standardColor
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }
}
