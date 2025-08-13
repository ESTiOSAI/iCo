//
//  String+ExtractJSON.swift
//  AIProject
//
//  Created by 장지현 on 8/4/25.
//

import SwiftUI

extension String {
    /// 문자열에 마크다운 JSON 코드 블록 추출 기능을 제공하는 String 확장
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
    
    /// 마크다운 형식의 문자열에서 불필요한 문자들을 제거하고 배열로 반환하는 확장
    /// - Returns: 원본 문자열의 내용을 "," 를 기준으로 분할해 담은 배열
    var convertIntoArray: [String] {
        // 네트워크 인코딩 문자, 줄바꿈 문자 제거하기
        let cleaned = self
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "[]\n\\\""))
        
        // "," 로 구분된 문자열이 존재하는 경우 배열로 분할하기
        if cleaned.contains(",") {
            let cleanArray = cleaned
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "\""))) }
                .filter { !$0.isEmpty }
            
            return cleanArray
        } else {
            // 빈 문자열일 경우 빈 배열로 반환하기
            return []
        }
    }
    
    /// AI 생성 답변 컨텐츠 안내 문구를 전역에서 재사용할 수 있도록 String 타입에 정적 프로퍼티로 추가하는 확장
    static var aiGeneratedContentNotice = "ⓘ 해당 컨텐츠는 생성형 AI가 생성한 응답으로 내용에 오류가 있을 수 있습니다. 투자 결정 시 유의하세요."

    /// 문자열 내의 숫자와 기호를 찾아 지정한 색상과 두께로 강조한 Text로 반환하는 확장
    ///  - Regex:
    ///  - `\\d{1,3}(?:,\\d{3})*` : 1~3자리 뒤에 `,`+3자리 반복 (예: `1,234`, `12,345,678`)
    ///  - `|\d+` : 콤마 없는 숫자 → `42`, `500`
    ///  - `(?:\.\d+)?` : 선택적 소수부 → `.5`, `.75`, `.123`
    ///  - %가 붙은 숫자만 매칭됨
    func highlightTextForNumbersOperator(highlightColor: Color = .blue, weight: Font.Weight = .bold) -> Text {
        let pattern = #"((?:\d{1,3}(?:,\d{3})*|\d+)(?:\.\d+)?\s?%)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return Text(self)
        }

        let ns = self as NSString
        let full = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: self, range: full)

        var last = 0
        var out = Text("")

        for m in matches {
            let r = m.range
            if r.location > last {
                out = out + Text(ns.substring(with: NSRange(location: last, length: r.location - last)))
            }
            let token = ns.substring(with: r)
            out = out + Text(token).foregroundColor(highlightColor).fontWeight(weight)
            last = r.location + r.length
        }
        if last < ns.length {
            out = out + Text(ns.substring(with: NSRange(location: last, length: ns.length - last)))
        }
        return out
    }
}
