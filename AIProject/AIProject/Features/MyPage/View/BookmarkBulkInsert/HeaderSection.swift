//
//  HeaderSection.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/11/25.
//

import SwiftUI

struct HeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("코인 목록이 캡쳐된 스크린샷을 업로드하세요.")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("아이코가 자동으로 북마크를 등록해드려요.")
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}
