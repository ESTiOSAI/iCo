//
//  Double+CurrencyFormat.swift
//  AIProject
//
//  Created by kangho lee on 8/4/25.
//

import Foundation

extension Double {
    
    /// 백만 단위의 원화 포맷팅
    func formattedCurrency() -> String {
        let millionValue = self / 1_000_000
        
        // NumberFormatter를 사용하여 로컬라이즈된 숫자 포맷을 적용
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        
        guard let formattedString = numberFormatter.string(from: NSNumber(value: millionValue)) else {
            return "\(millionValue)백만"  // 포맷 실패 시 기본값 반환
        }
        
        return "\(formattedString)백만"
    }
}
