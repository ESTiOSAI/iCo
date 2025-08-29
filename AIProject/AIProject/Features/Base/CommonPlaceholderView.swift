//
//  CommonPlaceholderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/27/25.
//

import SwiftUI

struct CommonPlaceholderView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    var imageName: String
    var text: String
    
    var body: some View {
        var showLogo: Bool { imageName == "logo" }
        
        ContentUnavailableView {
            Image(imageName)
                .renderingMode(showLogo ? .template : nil)
                .resizable()
                .scaledToFit()
                .frame(width: hSizeClass == .regular ? 200 : 130)
                .padding(50)
                .foregroundStyle(.aiCoLabelSecondary.opacity(colorScheme == .light ? 0.1 : 0.5))
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
