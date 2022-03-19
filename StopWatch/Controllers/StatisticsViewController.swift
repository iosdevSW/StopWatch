//
//  StatisticsViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/16.
//

import UIKit

class StatisticsViewController: UIViewController {
    //MARK: - Properties
    let calendarView: CalendarView = {
        let view = CalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendarMode = .month
        
        return view
    }()
    
    let previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("<", for: .normal)
        button.tag = 0
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    let nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(">", for: .normal)
        button.tag = 1
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "00:00:00"
        
        return label
    }()
    
    //MARK: - Init
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.addSubview()
        self.layout()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.rightBarButtonItems = [ UIBarButtonItem(customView: self.nextMonthButton),UIBarButtonItem(customView: self.previousMonthButton)]
        
        
    }
    
    //MARK: - Selector
    
    //MARK: - addsubView
    func addSubview(){
        self.view.addSubview(self.calendarView)
        self.view.addSubview(self.totalTimeLabel)
    }
    //MARK: - addTarget
    
    //MARK: - layout
    func layout(){
        NSLayoutConstraint.activate([
            self.calendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.calendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.calendarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.calendarView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        NSLayoutConstraint.activate([
            self.totalTimeLabel.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor, constant: 20),
            self.totalTimeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
}

extension StatisticsViewController: SaveDateDetectionDelegate {
    func detectSaveDate(date: String) {
        self.navigationItem.title = CalendarMethod().convertDate(date: date)
        let stringDate:(Int,Int,Int) = CalendarMethod().splitDate(date: date)
//        self.calendarView.year = stringDate.0
//        self.calendarView.month = stringDate.1
//        self.calendarView.day = stringDate.2
        
        self.calendarView.calendarView.reloadData()
    }
}
