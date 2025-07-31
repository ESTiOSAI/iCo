//
//  SubheaderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 7/30/25.
//

import SwiftUI

/// 서브헤더에 표시할 제목을 필수로 전달해주세요.
struct SubheaderView: View {
    @State var subheading: String
    
    var body: some View {
        HStack {
            Text(subheading)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.aiCoLabel)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")
}
