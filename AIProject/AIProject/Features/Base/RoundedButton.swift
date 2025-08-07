//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct RoundedButton: View {
    let buttonHeight: CGFloat = 32
    
    let title: String
    var image: Image? = Image(systemName: "chevron.right")
    var foregroundColor: Color = .aiCoLabel
    var backgroundColor: Color = .aiCoBackground
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12)).bold()
                    .foregroundStyle(foregroundColor)
                
                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                        .foregroundStyle(.aiCoLabelSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(.aiCoBackground.opacity(0.1))
            )
            .overlay {
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .stroke(.default, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    RoundedButton(title: "Hi", action: { print("Hi") })
}
