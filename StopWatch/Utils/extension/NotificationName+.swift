//
//  NotificationName+.swift
//  StopWatch
//
//  Created by SangWoo's MacBook on 2022/12/04.
//

import Foundation

extension Notification.Name {
    static let changeCalendarMode = Notification.Name("changeCalendarMode")
    static let presentAlert = Notification.Name("presentAlert")
    static let changeSaveDate = Notification.Name("changeSaveDate")
    static let closeColorEditView = Notification.Name("closeColorEditView")
    static let presentColorPicker = Notification.Name("presentColorPicker")
}
