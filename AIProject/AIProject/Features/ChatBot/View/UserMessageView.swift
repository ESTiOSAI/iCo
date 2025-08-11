//
//  UserMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct UserMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Spacer()
            Text(content)
                .font(.system(size: 13))
                .foregroundStyle(.aiCoLabel)
                .padding(15)
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
