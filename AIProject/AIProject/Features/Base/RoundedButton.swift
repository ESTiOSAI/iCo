//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct RoundedButton: View {
    let title: String
    var foregroundColor: Color = .gray
    var backgroundColor: Color = Color(.systemGray5)
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12)).bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(foregroundColor)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
    }
}
