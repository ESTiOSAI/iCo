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
            Spacer()
            Text(content)
                .font(.system(size: 13))
                .padding(15)
                .background(.aiCoBackground)
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .bottomLeft, .bottomRight]))
                .frame(maxWidth: 300, alignment: .trailing)
        }
    }
}
