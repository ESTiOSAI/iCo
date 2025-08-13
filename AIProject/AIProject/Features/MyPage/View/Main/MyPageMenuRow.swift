//
//  MyPageMenuRow.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/13/25.
//

import SwiftUI

struct MyPageMenuRow: View {
    var title: String
    var imageName: String
    
    var body: some View {
        HStack(spacing: 16) {
            CircleIconView(imageName: imageName)
            
            Text(title)
                .foregroundStyle(.aiCoLabel)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.aiCoLabelSecondary)
        }
    }
}
