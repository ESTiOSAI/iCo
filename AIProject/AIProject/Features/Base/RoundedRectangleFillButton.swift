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
///   - isHighlighted: 버튼이 탭되었을 때 버튼을 파란 스타일로 변경하기 위해 사용하는 Binding 변수
///   - action: (옵션)  버튼이 탭되었을 때 실행될 클로저
struct RoundedRectangleFillButton: View {
    let cornerRadius: CGFloat = 10
    
    var title: String
    var imageName: String?
    @Binding var isHighlighted: Bool
    
    var action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
        } label: {
            RoundedRectangleFillButtonView(title: title, isHighlighted: $isHighlighted)
        }
    }
}

#if DEBUG
func dummyAction() {
    print("sayHi")
}
#endif

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            RoundedRectangleFillButton(title: "가져오기", imageName: "square.and.arrow.down", isHighlighted: .constant(false)) { dummyAction() }
            RoundedRectangleFillButton(title: "내보내기", imageName: "square.and.arrow.up", isHighlighted: .constant(false)) { dummyAction() }
        }
        
        VStack(spacing: 16) {
            RoundedRectangleFillButton(title: "내보내기", isHighlighted: .constant(false)) { dummyAction() }
            RoundedRectangleFillButton(title: "내보내기", imageName: "square.and.arrow.up", isHighlighted: .constant(true))
        }
    }
    .padding(16)
}

struct RoundedRectangleFillButtonView: View {
    let cornerRadius: CGFloat = 10
    
    var title: String
    var imageName: String?
    @Binding var isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            if let imageName {
                Image(systemName: "\(imageName)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                    .foregroundStyle(!isHighlighted ? .aiCoLabelSecondary : .aiCoAccent)
                    .fontWeight(!isHighlighted ? .light : .regular)
                    .offset(y: -1) // 아이콘 위치 조정하기
            }
            
            Text(title)
                .frame(height: 36)
                .font(.system(size: 14, weight: !isHighlighted ? .regular : .medium))
                .foregroundStyle(!isHighlighted ? .aiCoLabel : .aiCoAccent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(!isHighlighted ? .aiCoBackground : .aiCoBackgroundAccent)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(!isHighlighted ? .default : .accent, lineWidth: 0.5)
        )
    }
}
