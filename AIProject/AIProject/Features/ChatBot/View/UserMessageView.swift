//
//  UserMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct UserMessageView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

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
                    RoundedCorner(radius: 16, corners: [.topLeft, .bottomLeft, .bottomRight])
                        .fill(Color.aiCoBackgroundWhite)
                }
                .overlay {
                    RoundedCorner(radius: 16, corners: [.topLeft, .bottomLeft, .bottomRight])
                        .stroke(Gradient.aiCoGradientStyle(.default), lineWidth: 0.5)
                }
                .frame(maxWidth: 300, alignment: .trailing)
        }
    }
}
