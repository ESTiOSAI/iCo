//
//  BotMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct BotMessageView: View {
    let content: String

    var body: some View {
        HStack {
            VStack {
                Image(systemName: "swift")
                    .foregroundStyle(.aiCoAccent)
                    .padding(8)
                    .background(Circle().stroke(Gradient.aiCoGradientStyle(.accent), lineWidth: 0.5))
                    .background {
                        Circle()
                            .fill(.aiCoBackgroundAccent)
                    }
                Spacer()
            }

            Text(content.isEmpty ? "..." : content)
                .foregroundStyle(.aiCoLabel)
                .font(.system(size: 13))
                .padding()
                .background {
                    RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])
                        .fill(.aiCoBackgroundAccent)
                }
                .overlay {
                    RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])
                        .stroke(Gradient.aiCoGradientStyle(.accent), lineWidth: 0.5)
                }
                .frame(maxWidth: 300, alignment: .leading)

            Spacer()
        }
    }
}
