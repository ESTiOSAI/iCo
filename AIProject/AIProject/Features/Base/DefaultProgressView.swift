//
//  DefaultProgressView.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct DefaultProgressView: View {
    let message: String
    let messagetintColor: Color = Color.aiCoLabel
    let barTintColor: Color = Color.aiCoLabel
    let font: Font
    let spacing: CGFloat

    var body: some View {
        VStack(spacing: spacing) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: barTintColor))
                .scaleEffect(1.2) // 크기 살짝 키우기

            Text(message)
                .font(font)
                .foregroundColor(messagetintColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}
