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
    
    /// 백만 단위의 원화 포맷팅
    var formatMillion: String {
        let millionValue = self / 1_000_000
        
        // NumberFormatter를 사용하여 로컬라이즈된 숫자 포맷을 적용
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        guard let result = formatter.string(from: NSNumber(value: millionValue)) else {
            return "\(millionValue)백만"  // 포맷 실패 시 기본값 반환
        }
        
        return "\(result)백만"
    }
}
