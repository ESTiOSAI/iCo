//
//  RoundedRectangleButton.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/8/25.
//

import SwiftUI

/// 둥근 사각형 배경과 텍스트, 선택적 아이콘을 포함한 커스터마이즈 가능한 버튼 뷰
/// 활성 상태(`isActive`)에 따라 색상과 테두리 스타일이 달라짐
/// 
/// - Parameters:
///   - title: 버튼에 표시할 텍스트
///   - imageName: (옵션) `SF Symbols` 아이콘 이름. 텍스트 왼쪽에 아이콘이 표시됨
///   - isActive: 버튼의 활성 상태. 기본값은 `false`이며, `true`일 경우 강조된 색상과 테두리가 적용됨
///   - action: 버튼이 눌렸을 때 실행될 동작을 정의하는 클로저
struct RoundedRectangleButton: View {
    let cornerRadius: CGFloat = 10
    
    var title: String
    var imageName: String?
    var isActive: Bool = false
    
    var action: (() -> Void)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let imageName {
                    Image(systemName: "\(imageName)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .foregroundStyle(.aiCoLabelSecondary)
                        .fontWeight(.light)
                        .offset(y: -1)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isActive ? .aiCoAccent : .aiCoLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isActive ? .aiCoBackgroundAccent : .aiCoBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isActive ? .accent : .default, lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    VStack {
        RoundedRectangleButton(title: "가져오기") { dummyAction() }
        RoundedRectangleButton(title: "가져오기", isActive: true) { dummyAction() }
    }
}
