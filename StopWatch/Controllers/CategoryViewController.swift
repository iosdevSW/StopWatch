//
//  CategoryEditViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/26.
//

import UIKit
import RealmSwift
import SnapKit
import Then

final class CategoryViewController: UIViewController {
    //MARK: - Properties
    var saveDate = ""
    let realm = try! Realm()
    
    private let categoryTableView = UITableView().then {
        $0.register(CategoryCell.self, forCellReuseIdentifier: "categoryCell")
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        if #available(iOS 15, *) {
            $0.sectionHeaderTopPadding = 0
        }
    }
    
    //MARK: - Init
    deinit {
        print("CategoryEditViewController Deinit")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad(){
        super.viewDidLoad()
        self.configure()
        self.AddSubView()
        self.layout()
        
        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        
        self.hideKeyboardWhenTapped()
        self.setBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).resetDate
        StopWatchDAO().create(date: self.saveDate)
        
        self.categoryTableView.reloadData()
        self.configureNavigationBar()
    }
    
    //MARK: - Method 
    private func deleteCategory(point: CGPoint) {
        if let indexPath = self.categoryTableView.indexPathForRow(at: point) {
            StopWatchDAO().deleteSegment(row: indexPath.row)
            StopWatchDAO().create(date: self.saveDate)
            self.categoryTableView.reloadData()
        }
    }
    
    private func setBarButtonItem() {
        let addCategoryBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(self.addBarButtonItemMtd)).then {
           $0.tintColor = .lightGray
        }
        self.navigationItem.rightBarButtonItem = addCategoryBarButtonItem
        self.navigationItem.title = "Category"
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()    // 불투명하게
            appearance.backgroundColor = .white
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance    // 동일하게 만들기
        }else {
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    //MARK: - Configure
    private func configure(){
        self.view.backgroundColor = .white
        self.navigationItem.title = "Category"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    //MARK: - AddSubView
    private func AddSubView() {
        self.view.addSubview(self.categoryTableView)
    }
    
    //MARK: - Layout
    private func layout(){
        self.categoryTableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Selector
    @objc func addBarButtonItemMtd(){
        let editVC = EditCategoryViewController()
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.categoryTableView)
        
        if let indexPath = self.categoryTableView.indexPathForRow(at: point) {
            let segment = self.realm.objects(Segments.self)
            let name = segment[indexPath.row].name
            
            self.defaultAlert(title: nil, message: name + "를 삭제 하시겠습니까?") {
                self.deleteCategory(point: point)
            }
        }
    }
    
    //MARK: - SetGesture
    private func setLongPressGesture(cell: CategoryCell){
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(self.longPressGesture(gesture:)))
        cell.addGestureRecognizer(gesture)
    }
}

//MARK: TableViewDelegate
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let segment = self.realm.objects(Segments.self)
        return segment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        self.setLongPressGesture(cell: cell)
        
        if let segment = StopWatchDAO().getDailyData(self.saveDate)?.dailySegment[indexPath.row] {
            cell.configureCell(segment)
        } else {
            let segment = self.realm.objects(Segments.self)[indexPath.row]
            cell.configureCell(segment)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segment = self.realm.objects(Segments.self)
        let editVC = EditCategoryViewController().then {
            $0.selectedSegmentRow = indexPath.row
            $0.getNameTextField.text = segment[indexPath.row].name
            $0.selectedColorCode = segment[indexPath.row].colorCode
        }
       
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return PreView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.view.frame.height * 0.3
    }
}


    
