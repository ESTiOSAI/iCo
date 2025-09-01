//
//  UserMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

/// 유저 메세지에 해당하는 View입니다.
struct UserMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Spacer()
            Text(content)
                .font(.system(size: 14))
                .lineSpacing(6)
                .foregroundStyle(.aiCoLabel)
                .padding(.vertical, 15)
                .padding(.horizontal, 18)
                .background {
                    UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 16)
                        .fill(Color.aiCoBackgroundWhite)
                }
                .overlay {
                    UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 16)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                }
                .frame(maxWidth: 300, alignment: .trailing)
        }
    }
}
