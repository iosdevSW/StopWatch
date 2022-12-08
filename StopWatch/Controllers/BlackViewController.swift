//
//  BlackViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2021/08/23.
//

import UIKit

protocol TimerTriggreDelegate: AnyObject {
    func timerStop(_ startDate: TimeInterval)
}

final class BlackViewController: UIViewController {
    weak var delegate: TimerTriggreDelegate?
    var startDate: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDate = Date().timeIntervalSince1970
        self.generatePhone()
        
        self.view.backgroundColor = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.timerStop(self.startDate)
    }
    
    private func generatePhone(){
        let generator = UIImpactFeedbackGenerator(style:.heavy)
        generator.impactOccurred()
    }
    
}
