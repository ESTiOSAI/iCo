//
//  CommonPlaceholderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/27/25.
//

import SwiftUI

struct CommonPlaceholderView: View {
    var imageName: String
    var text: String
    
    var body: some View {
        ContentUnavailableView {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .padding(50)
                .background(.aiCoBackground)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                }
                .padding(.bottom, 16)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.aiCoLabelSecondary)
                .lineSpacing(6)
        }
    }
}
