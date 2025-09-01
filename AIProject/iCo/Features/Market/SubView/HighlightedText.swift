//
//  HighlightedText.swift
//  AIProject
//
//  Created by kangho lee on 8/26/25.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let searchTerm: String
    
    var body: some View {
        if searchTerm.isEmpty {
            Text(text)
        } else {
            Text(makeHighlightedString(text: text, searchTerm: searchTerm))
        }
    }
    
    private func makeHighlightedString(text: String, searchTerm: String) -> AttributedString {
        var attributed = AttributedString(text)
        
        // 대소문자 무시하고 검색
        let lowercasedText = text.lowercased()
        let lowercasedSearch = searchTerm.lowercased()
        
        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex
        
        while let range = lowercasedText.range(of: lowercasedSearch, range: searchRange) {
            let nsRange = NSRange(range, in: text)
            if let attributedRange = Range(nsRange, in: attributed) {
                attributed[attributedRange].foregroundColor = .aiCoAccent
            }
            
            // 다음 검색 시작 위치 이동
            searchRange = range.upperBound..<lowercasedText.endIndex
        }
        
        return attributed
    }
}
