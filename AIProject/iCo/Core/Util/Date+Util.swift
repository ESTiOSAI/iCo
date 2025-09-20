//
//  Date+Util.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/24/25.
//

import Foundation

/// `Date` 타입에 날짜와 시간을 지정된 형식으로 포맷팅하는 기능을 추가하는 확장.
///
/// - Static Property:
///   - dateAndTimeFormatter: `"yyyy.MM.dd HH:mm"` 형식의 `DateFormatter`.
///
/// - Computed Property:
///   - dateAndTime: `Date` 인스턴스를 지정된 형식의 문자열로 변환.
///
/// 사용 예시:
/// let now = Date()
/// print(now.dateAndTime) // "2025.08.24 22:15"
extension Date {
    static let dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var dateAndTime: String {
        Date.dateAndTimeFormatter.string(from: self)
    }
}

/// `Date` 타입에 시간을 지정된 형식으로 포맷팅하는 기능을 추가하는 확장.
///
/// - Static Property:
///   - hhmmTimeFormatter: `"HH:mm"` 형식(24시간제)의 `DateFormatter`.
///
/// - Computed Property:
///   - hhmmTime: `Date` 인스턴스를 지정된 형식의 문자열로 변환.
///
/// 사용 예시:
/// let now = Date()
/// print(now.hhmmTime) // "13:05"
extension Date {
    static let hhmmTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
 
    var hhmmTime: String {
        Date.hhmmTimeFormatter.string(from: self)
    }
    
    static let numbersOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var numbersOnly: String {
        Date.numbersOnlyFormatter.string(from: self)
    }
}

extension Date {
    var asUpbitISO8601: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
}
