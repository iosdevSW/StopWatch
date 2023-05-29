//
//  Segments.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/29.
//

import Foundation
import RealmSwift

class Segments: Object {
    @Persisted(primaryKey: true) var id : String = UUID().uuidString // 과목번호
    @Persisted var name: String // 과목명
    @Persisted var colorCode: Int //과목색상코드
}
