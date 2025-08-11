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
            VStack {
                Image(systemName: "swift")
                    .foregroundStyle(.blue)
                    .padding(8)
                    .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                Spacer()
            }

            Group {
                Text(content.isEmpty ? "..." : content)
            }
            .font(.system(size: 13))
            .padding()
            .background(.aiCoBackground)
            .clipShape(RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight]))
            .frame(maxWidth: 300, alignment: .leading)

            Spacer()
        }
    }
}
