//
//  HeaderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 7/30/25.
//

import SwiftUI

/// 헤더에 표시할 제목을 필수로 전달해주세요.
/// 마켓이나 북마크 메뉴일 경우 각 파라메터에 true 값을 넣어주세요.
struct HeaderView: View {
    let heading: String
    
    var showSearchButton = false
    var isBookmarkView = false
    
    var body: some View {
        HStack {
            Text(heading)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(.aiCoLabel)
            
            Spacer()
            
            if showSearchButton {
                Button {
                    print("Hi")
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .fontWeight(.medium)
                        .foregroundStyle(.aiCoLabel)
                }
            } else if isBookmarkView {
                // 북마크 메뉴라면 북마크 관리 버튼 보여주기
                HStack(spacing: 8) {
                    Group {
                        Button {
                            // 가져오기 기능 구현하기
                        } label: {
                            Text("가져오기")
                        }
                        
                        Button {
                            // 내보내기 기능 구현하기
                        } label: {
                            Text("내보내기")
                        }
                    }
                    .font(.system(size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(.aiCoLabel)
                    .background(.aiCoBackground)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HeaderView(heading: "북마크 관리", isBookmarkView: true)
        .padding(.bottom, 16)
    SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")
}
