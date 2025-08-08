//
//  RoundedRectangleFillButton.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/8/25.
//

import SwiftUI

/// 아이콘과 텍스트를 포함하며, 배경이 채워진 스타일의 둥근 사각형 버튼 뷰
/// 상위 뷰가 지정한 전체 너비를 채움
///
/// - Parameters:
///   - title: 버튼에 표시될 텍스트
///   - imageName: (옵션) `SF Symbols` 이름. 아이콘이 텍스트 왼쪽에 표시됨
///   - action: 버튼이 탭되었을 때 실행될 클로저
struct RoundedRectangleFillButton: View {
    let cornerRadius: CGFloat = 10
    
    var title: String
    var imageName: String?
    
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
                    .frame(height: 36)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.aiCoLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.aiCoBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.default, lineWidth: 0.5)
            )
        }
    }
}

func dummyAction() {
    print("sayHi")
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            RoundedRectangleFillButton(title: "가져오기", imageName: "square.and.arrow.down") { dummyAction() }
            RoundedRectangleFillButton(title: "내보내기") { dummyAction() }
        }
        
        VStack(spacing: 16) {
            RoundedRectangleFillButton(title: "내보내기") { dummyAction() }
        }
    }
    .padding(16)
}
