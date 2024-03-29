//
//  Palette.swift
//  StopWatch
//
//  Created by 신상우 on 2023/05/29.
//

import Foundation
import RealmSwift

class Palettes: Object {
    @Persisted var colorCode: Int // 16진수 색상코드 (UIColor는 저장 안되니까 코드로 저장)
}

struct Palette {
    var paints: [Int] = [
        0xB4585A, /* #b4585a */
        0xFB9DA7, /* #fb9da7 */
        0xFCCCD4, /* #fcccd4 */
        0xD09069, /* #d09069 */
        0xFBD2A2, /* #fbd2a2 */
        0xF2E2C6, /* #f2e2c6 */
        0x676A59, /* #676a59 */
        0x8EB695, /* #8eb695 */
        0x768AA2, /* #768aa2 */
        0xA3ABE0, /* #a3abe0 */
        0x474566, /* #474566 */
        0xd2bce1, /* #d2bce1 */
        0xECECEC, /* #ececec */
        0xCEBBB5, /* #cebbb5 */
        0x867674, /* #867674 */
        0xCC9E8E, /* #cc9e8e */
        0xE6D5C3, /* #e6d5c3 */
        0xECE7E0, /* #ece7e0 */
        0xDAEDE1, /* #daede1 */
        0xABCDBB, /* #abcdbb */
        0xD9DDA8, /* #d9dda8 */
        0xE6EDCE, /* #e6edce */
        0xE9F1E9, /* #e9f1e9 */
        0xEFF7F7  /* #eff7f7 */
    ]
}
