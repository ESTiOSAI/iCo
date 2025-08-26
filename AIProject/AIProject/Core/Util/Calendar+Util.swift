//
//  Calendar+Util.swift
//  AIProject
//
//  Created by 강민지 on 8/26/25.
//

import Foundation

/// 지정 타임존을 적용한 Gregorian 캘린더를 생성하는 유틸리티.
///
/// - Parameter timeZone: 계산에 사용할 타임존(예: `"Asia/Seoul"`).
/// - Returns: 지정 타임존을 포함한 `Calendar(identifier: .gregorian)`.
///
/// - 설명:
///   라벨 포맷터가 사용하는 타임존과 동일한 캘린더로
///   X축 틱(00/15/30/45) 생성과 정시(00분) 그리드 판정을 수행할 때 사용합니다.
///   이렇게 하면 라벨과 그리드가 정확히 정렬됩니다.
///
/// - 사용 예시:
///   let tz = TimeZone(identifier: "Asia/Seoul") ?? .current
///   let cal = Calendar.gregorian(timeZone: tz)
extension Calendar {
    static func gregorian(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
