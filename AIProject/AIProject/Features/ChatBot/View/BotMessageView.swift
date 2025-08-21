//
//  BotMessageView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct BotMessageView: View {
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
                            .stroke(.accentGradient, lineWidth: 0.5)
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
            .font(.system(size: 13))
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background {
                RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])
                    .fill(.aiCoBackgroundAccent)
            }
            .overlay {
                RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])
                    .stroke(.accentGradient, lineWidth: 0.5)
            }
            .frame(maxWidth: 300, alignment: .leading)

            Spacer()
        }
    }
}
