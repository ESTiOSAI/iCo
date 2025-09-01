//
//  BadgeLabelView.swift
//  AIProject
//
//  Created by 강민지 on 8/5/25.
//

import SwiftUI

/// 재사용 가능한 라벨 뱃지 (ex: 코인 심볼)
struct BadgeLabelView: View {
    let text: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(
        text: String,
        foregroundColor: Color = .gray,
        backgroundColor: Color = Color(.systemGray5)
    ) {
        self.text = text
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(foregroundColor)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}
