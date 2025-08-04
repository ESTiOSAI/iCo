//
//  String+ExtractJSON.swift
//  AIProject
//
//  Created by 장지현 on 8/4/25.
//

import Foundation

/// 문자열에 마크다운 JSON 코드 블록 추출 기능을 제공하는 String 확장
extension String {
    /// 마크다운 형식의 문자열에서 ```json으로 시작하고 ```로 끝나는 JSON 코드 블록의 내용을 추출하는 계산 속성
    ///
    /// - Returns: 코드 블록이 존재할 경우 추출된 JSON 문자열, 없을 경우 원본 문자열
    var extractedJSON: String {
        guard let startRange = self.range(of: "```json") else { return self }
        guard let endRange = self.range(of: "```", options: .backwards) else { return self }
        
        let jsonStartIndex = self.index(after: startRange.upperBound)
        let jsonString = self[jsonStartIndex..<endRange.lowerBound]
        
        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
