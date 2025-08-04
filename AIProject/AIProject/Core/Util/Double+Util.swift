//
//  Double+Util.swift
//  AIProject
//
//  Created by 강대훈 on 8/4/25.
//

import Foundation

extension Double {
    /// KRW(원화) 형태인 문자열로 반환합니다. (ex. 1,600원)
    var formatKRW: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")

        guard let krw = formatter.string(from: NSNumber(value: self)) else {
            return "잘못된 포맷입니다."
        }

        return "\(krw)원"
    }

    /// Rate 형태인 문자열로 반환합니다. (ex. 4.27%)
    var formatRate: String {
        String(format: "%.2f%%", self)
    }
}
