//
//  MenuViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit
import Then
import SnapKit

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
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .standardColor
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        self.view.addSubview(self.menuTableView)
        self.menuTableView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(160)
        }
    }
}

extension MenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuOptionCell", for: indexPath) as! MenuOptionCell
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.configureCell(menuOption)
        
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
