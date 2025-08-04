//
//  MyPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MyPageView: View {

    var body: some View {
        NavigationView {
            VStack {
                HeaderView(heading: "마이페이지")
                    .padding(.bottom)

                List {
                    NavigationLink("북마크 관리", destination: BookmarkView())
                    NavigationLink("알림 설정", destination: AlarmView())
                    NavigationLink("차트 색상 변경", destination: ThemeView())
                    NavigationLink("문의하기", destination: BookmarkView())
                    NavigationLink("개인정보처리방침", destination: PrivacyPolicyView())
                }
                .listStyle(.plain)
                .font(.system(size: 15, weight: .regular))
            }
        }
    }
}

#Preview {
    MyPageView()
}
