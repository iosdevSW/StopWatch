//
//  CategoryEditViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/04/26.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {
    //MARK: Properties
    let palette = Palette()
    var saveDate = ""
    let realm = try! Realm()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CategoryCell.self, forCellReuseIdentifier: "categoryCell")
        self.view.addSubview(view)
        view.separatorStyle = .none
        view.backgroundColor = .white
        if #available(iOS 15, *) {
            view.sectionHeaderTopPadding = 0
        }

        return view
    }()
    
    lazy var addCategoryBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addBarButtonItemMtd))
        button.tintColor = .lightGray
        
        return button
    }()
    
    //MARK: Init
    deinit {
        print("CategoryEditViewController Deinit")
    }
    
    //MARK: Method
    override func viewDidLoad(){
        super.viewDidLoad()
        self.configure()
        self.layOut()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.hideKeyboardWhenTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.saveDate = (UIApplication.shared.delegate as! AppDelegate).resetDate
        StopWatchDAO().create(date: (UIApplication.shared.delegate as! AppDelegate).resetDate)
        self.tableView.reloadData()
        
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
    
    //과목 색상 인덱스 찾는 함수
    func findRow(_ segmentRow: Int) -> Int? {
        let objects = self.realm.objects(Palettes.self)
        let colorCode = self.realm.objects(Segments.self)[segmentRow].colorCode
        var index = 0
        for element in objects {
            if element.colorCode == colorCode {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func deleteCategory(point: CGPoint){
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            let segment = self.realm.objects(Segments.self)[indexPath.row]
            
            let filter = self.realm.objects(SegmentData.self).where{
                $0.segment == segment
            }
            
            try! self.realm.write{
                for data in filter {
                    self.realm.delete(data)
                }
                self.realm.delete(segment)
            }
            StopWatchDAO().create(date: self.saveDate)
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: Configure
    func configure(){
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = addCategoryBarButtonItem
        self.navigationItem.title = "Category"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    //MARK: LayOut
    func layOut(){
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -22),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 22),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    //MARK: Selector
    @objc func addBarButtonItemMtd(){
        let editVC = EditCategoryViewController()
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer){
        let point = gesture.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            let segment = self.realm.objects(Segments.self)
            let name = segment[indexPath.row].name
            
            let alert = UIAlertController(title: nil, message: name + "를 삭제 하시겠습니까?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) {(_) in
                self.deleteCategory(point: point)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
            
        }
    }
    
    //MARK: setGesture
    func setLongPressGesture(cell: CategoryCell){
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
        let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
        let segment = filter!.dailySegment
        let value = segment[indexPath.row].value 
        let colorCode = self.realm.objects(Segments.self)[indexPath.row].colorCode
        let name = self.realm.objects(Segments.self)[indexPath.row].name

        let (subSecond,second,minute,hour) = self.view.divideSecond(timeInterval: value )

        
        cell.nameLabel.text = name
        cell.colorView.backgroundColor = self.view.uiColorFromHexCode(colorCode)
        cell.subValueLabel.text = subSecond
        cell.valueLabel.text = "\(hour) : \(minute) :  \(second)"
        
        cell.selectionStyle = .none
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            let filter = self.realm.object(ofType: DailyData.self, forPrimaryKey: self.saveDate)
//            if let todaySegment = filter?.dailySegment[indexPath.row]{
//                try! self.realm.write{
//                    self.realm.delete(todaySegment)
//                }
//            }
//            let segment = self.realm.objects(Segments.self)[indexPath.row]
//
//            try! self.realm.write{
//                self.realm.delete(segment)
//            }
//            tableView.reloadData()
//        }
//    }
//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = EditCategoryViewController()
        let segment = self.realm.objects(Segments.self)
        self.navigationController?.pushViewController(editVC, animated: true)
        editVC.selectedSegmentRow = indexPath.row
        editVC.getNameTextField.text = segment[indexPath.row].name
        editVC.selectedColorCode = segment[indexPath.row].colorCode
        if let colorRow = findRow(indexPath.row) {
            editVC.selectedColorRow = colorRow
            print(colorRow)
        }
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


    
