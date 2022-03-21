//
//  ContainerViewController.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit

class ContainerViewController: UIViewController {
    //MARK: - Properties
    var homeVC: UIViewController!
    var menuVC: MenuViewController!
    var StopWatchVC: StopWatchViewController!
    var isExpanded = false
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .standardColor
        self.configureStopWatchViewController()
    }
    
    // StopWatchVC 구성 함수
    func configureStopWatchViewController() {
        self.StopWatchVC = StopWatchViewController() // 메인홈컨트롤러 객체 생성
        self.homeVC = UINavigationController(rootViewController: self.StopWatchVC) // 네비게이션컨트롤러 생성
        self.StopWatchVC.delegate = self
        
        self.view.addSubview(self.homeVC.view) // stopWatch의 뷰를 container 뷰의 자식뷰로 추가
        self.addChild(self.homeVC) // 컨테이너VC의 자식 컨트롤러로 StopWatchVC를 추가
        self.homeVC.didMove(toParent: self) // 부모VC가 바뀜을 알림
        
        // add gestrue
        let leftGesture = UISwipeGestureRecognizer()
        leftGesture.direction = .left
        let rightGesture = UISwipeGestureRecognizer()
        rightGesture.direction = .right
        
        self.StopWatchVC.frameView.addGestureRecognizer(leftGesture)
        self.StopWatchVC.frameView.addGestureRecognizer(rightGesture)
        
        leftGesture.addTarget(self, action: #selector(self.respondToswipe(gesture:)))
        rightGesture.addTarget(self, action: #selector(self.respondToswipe(gesture:)))
    }
    
    // 메뉴VC 구성 함수
    func ConfigureMenuViewController() {
        if self.menuVC == nil {
            self.menuVC = MenuViewController()
            self.menuVC.delegate = self
            
            self.view.insertSubview(self.menuVC.view, at: 0)
            self.addChild(self.menuVC)
            self.menuVC.didMove(toParent: self)
        }
    }
    
    // isExpanded(메뉴 확장여부)에 따라 Animate처리하는 함수
    func animatePanel(isExpand: Bool, MenuOption: MenuOption?){
        if isExpand {
            // show menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = 160 // 왼쪽으로
            }, completion: nil)
            
        }else {
            //hide menu
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeVC.view.frame.origin.x = 0
            }){ (_) in // 선택한 옵션이 있으면 옵션에 해당하는 함수 실행, 없으면 그냥 닫힘
                guard let MenuOption = MenuOption else { return }
                self.StopWatchVC.didSelectedMenuOption(menuOption: MenuOption)
            }
            
        }
    }
    //MARK: - Selector
    
    @objc func respondToswipe(gesture: UISwipeGestureRecognizer) {
        if !self.isExpanded {
            self.ConfigureMenuViewController()
        }
        
        switch gesture.direction {
        case .left:
            self.isExpanded = false
        case .right:
            self.isExpanded = true
        default:
            print("default")
        }
        self.animatePanel(isExpand: self.isExpanded, MenuOption: nil)
    }
}

extension ContainerViewController: StopWatchVCDelegate {
    func handleMenuToggle(menuOption: MenuOption?) {
        if !self.isExpanded {
            self.ConfigureMenuViewController()
        }
        self.isExpanded = !isExpanded // toggle
        self.animatePanel(isExpand: self.isExpanded, MenuOption: menuOption)
    }
    
    func closeMenu() {
        self.isExpanded = false
        self.animatePanel(isExpand: self.isExpanded, MenuOption: nil)
    }
}
