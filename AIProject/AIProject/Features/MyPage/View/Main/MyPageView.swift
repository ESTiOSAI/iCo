//
//  MyPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MyPageView: View {

    var body: some View {
        NavigationStack {
            VStack() {
                HeaderView(heading: "마이페이지")
                
                VStack(spacing: 16) {
                    Group {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("개인화 설정")
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 16) {
                                NavigationLink {
                                    BookmarkView()
                                } label: {
                                    MyPageMenuRow(title: "북마크 설정", imageName: "bookmark")
                                }
                                
                                NavigationLink {
                                    ThemeView()
                                } label: {
                                    MyPageMenuRow(title: "알림 설정", imageName: "bell.badge")
                                }
                                
                                NavigationLink {
                                    ThemeView()
                                } label: {
                                    MyPageMenuRow(title: "테마 변경", imageName: "paintpalette")
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("기타 설정")
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 16) {
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    MyPageMenuRow(title: "문의하기", imageName: "at")
                                }
                                
                                NavigationLink {
                                    PrivacyPolicyView()
                                } label: {
                                    MyPageMenuRow(title: "인공지능(AI) 윤리기준", imageName: "sparkles")
                                }
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.aiCoLabel)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.aiCoBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.default, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MyPageView()
}
