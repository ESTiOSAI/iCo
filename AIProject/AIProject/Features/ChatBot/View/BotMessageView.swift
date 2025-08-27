//
//  BotMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct BotMessageView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    @State private var bounce = false

    let message: ChatMessage

    var body: some View {
        HStack {
            VStack {
                Image(systemName: "swift")
                    .foregroundStyle(.aiCoAccent)
                    .padding(8)
                    .overlay {
                        Circle()
                            .strokeBorder(.accentGradient, lineWidth: 0.5)
                    }
                    .background {
                        Circle()
                            .fill(.aiCoBackgroundAccent)
                    }
                Spacer()
            }

            Group {
                if message.content.isEmpty {
                    Image(systemName: "ellipsis")
                        .symbolEffect(.bounce, value: bounce)
                        .onAppear { bounce = true }
                        .onDisappear { bounce = false }
                } else {
                    Text(message.content)
                }
            }
            .foregroundStyle(message.isError ? .aiCoPositive : .aiCoLabel)
            .font(.system(size: 14))
            .lineSpacing(6)
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background {
                UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 16)
                    .fill(.aiCoBackgroundAccent)
            }
            .overlay {
                UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 16)
                    .strokeBorder(.accentGradient, lineWidth: 0.5)
            }
            .frame(maxWidth: 300, alignment: .leading)

            Spacer()
        }
    }
}
