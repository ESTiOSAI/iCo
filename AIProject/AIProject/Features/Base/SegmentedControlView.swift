//
//  SegmentedControlView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

/// 사용자 지정 세그먼트 컨트롤 뷰
///
/// 이 뷰는 `tabTitles`에 지정된 탭 제목을 표시하고,
/// 현재 선택된 탭을 `selection` 바인딩을 통해 제어합니다.
///
/// - Parameters:
///   - selection: 현재 선택된 탭 인덱스를 나타내는 바인딩 변수
///   - tabTitles: 각 탭에 표시할 제목 문자열 배열
///   - width: SegmentedControl 너비를 지정하는 값, 기본값은 150
struct SegmentedControlView: View {
    /// 선택된 탭의 언더라인 애니메이션을 위한 네임스페이스
    @Namespace private var underlineAnimation
    /// 현재 선택된 탭 인덱스를 나타내는 바인딩 변수
    @Binding var selection: Int
    /// 각 탭에 표시할 제목 문자열 배열
    let tabTitles: [String]
    /// SegmentedControl 너비 (기본값 150)
    var width: CGFloat = 150
    
    /// 뷰 계층 구조를 정의하고, 각 탭 버튼과 배경을 구성합니다.
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabTitles.count, id: \.self) { idx in
                Button {
                    withAnimation(.easeInOut) {
                        selection = idx
                    }
                } label: {
                    Text(tabTitles[idx])
                        .font(.system(size: 15, weight: selection == idx ? .bold : .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundColor(selection == idx ? .aiCoBackgroundWhite : .aiCoLabelSecondary)
                        .background(
                            ZStack {
                                if selection == idx {
                                    Capsule()
                                        .fill(.aiCoAccent)
                                        .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                                }
                            }
                        )
                }
            }
        }
        .padding(8)
        .background(.aiCoBackgroundAccent)
        .frame(width: width)
        .clipShape(Capsule())
        .overlay { Capsule().stroke(.defaultGradient, lineWidth: 0.5) }
    }
}

#Preview {
    SegmentedControlView(selection: .constant(0), tabTitles: ["1D", "1D", "1D", "1D", "1D"], width: 320)
        .padding()
}
