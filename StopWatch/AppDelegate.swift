//
//  AppDelegate.swift
//  StopWatch
//
//  Created by 신상우 on 2021/03/23.
//

import UIKit
import RealmSwift
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let realm = try! Realm()
    
    var saveDate: String { // 오늘 날짜 반환!
        return self.date()
    }
    
    var resetDate: String {
        return self.returnResetDate()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ContainerViewController()
        window?.makeKeyAndVisible()
        
        self.setFirstDB() // 아무 과목도 없을시  기타 과목 추가
        
        let ud = UserDefaults.standard
        if ud.bool(forKey: "FirstPalette") == false { self.setFirstPalette() }
        
        FirebaseApp.configure()
        
        return true
    }
    
    //오늘 날짜 리턴 메소드
    func date() -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.identifier)
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: Date() )
    }
    
    func returnResetDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.identifier)
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        let interval = TimeInterval(-3600 * 4) // 4시에 리셋
        let date = Date().addingTimeInterval(interval)
        
        return formatter.string(from: date )
    }
    
    //DB 아무것도 없을 때 기본 과목 설정.
    func setFirstDB(){
        try! realm.write{
            if realm.objects(Segments.self).count == 0 {
                let data = Segments()
                data.colorCode = 0xECE7E0
                data.name = "기타"
                
                realm.add(data)
            }
        }
    }
    
    // 처음 앱 시작시 팔레트에 색 채우기.
    private func setFirstPalette(){
        let paints = Palette().paints
        for color in paints {
            let palettes = Palettes()
            palettes.colorCode = color
            try! realm.write{
                realm.add(palettes)
            }
        }
        let ud = UserDefaults.standard
        ud.set(true, forKey: "FirstPalette")
        ud.synchronize()
    }
    
}

