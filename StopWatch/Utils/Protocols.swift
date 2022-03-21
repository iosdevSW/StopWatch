//
//  Protocols.swift
//  StopWatch
//
//  Created by 신상우 on 2022/03/13.
//

import UIKit

protocol StopWatchVCDelegate {
    func handleMenuToggle(menuOption: MenuOption?)
    func closeMenu()
}
// 구현 자유!
extension StopWatchVCDelegate {
    func closeMenu() { }
}

protocol SaveDateDetectionDelegate {
    func detectSaveDate(date: String)
}
