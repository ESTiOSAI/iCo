//
//  DashboardView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

/// 메인 화면에 다양한 코인 관련 섹션을 보여주는 대시보드 뷰입니다.
///
/// 관심 코인 기반 추천, AI 브리핑으로 구성합니다.
struct DashboardView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Namespace var coordinateSpaceName: Namespace.ID
    /// 스크롤의 위치를 저장하는 상태 변수
    @State var scrollOffset: CGFloat = 0
    /// 상단 여백을 저장하는 상태 변수: onAppear에서 실제 높이를 계산함
    @State var topInset: CGFloat = 0
    
    /// 배경색의 높이를 저장하는 계산 속성: 헤더의 높이 + 여백 + 카드의 높이 / 2 + 상단 여백
    /// 배경이 카드의 중앙까지만 깔리게 해야 하는데 뷰가 여러 계층으로 나눠져있어서 각 컴포넌트의 높이를 계산해서 사용함
    var gradientHeight: CGFloat {
        CardConst.headerHeight + CardConst.headerContentSpacing + (CardConst.cardHeight / 2) + topInset
    }
    
    var body: some View {
        /// 배경색에 Sticky 효과 적용을 위해 추가적인 높이: 스크롤 위치만큼 더해주기 위해 사용
        /// 쫀득한 효과를 더 드라마틱하게 보여주기 위해 스크롤 위치의 1.2배만큼 늘리기
        let extraHeight = max(0, -scrollOffset * 1.2)
        
        GeometryReader { outerProxy in
            NavigationStack {
                ScrollView {
                    VStack {
                        RecommendCoinView()
                        AIBriefingView()
                    }
                    .padding(.top, topInset)
                    .background {
                        // scrollOffset을 구하기 위해 ScrollOffsetPreferenceKey 적용하기
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: -proxy.frame(in: .named(coordinateSpaceName)).minY
                                )
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: coordinateSpaceName)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                .background(alignment: .top) {
                    // 메인 그레디언트 배경
                    LinearGradient(
                        colors: [.aiCoBackgroundGradientLight, .aiCoBackgroundGradientProminent],
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                    .frame(height: gradientHeight + extraHeight)
                    .offset(y: scrollOffset < 0 ? 0 : -scrollOffset)
                }
                .ignoresSafeArea(edges: .top)
                .safeAreaInset(edge: .top) {
                    // 아이폰일 때 스크롤 내리면 커스텀 네비게이션바 보여주기
                    if hSizeClass == .compact {
                        CustomNavigationBar(scrollOffset: scrollOffset, topInset: topInset)
                    }
                }
            }
            .onAppear {
                // 아이패드에서 다른 탭으로 갔다 돌아오면 topInset이 변경되는 이슈가 있어 초기값이 0일 때만 업데이트되도록 제한
                // 아마도 네비게이션바나 상단 탭바 관련 값이 변경돼서 재계산하는 것으로 의심됨
                if topInset == 0 {
                    topInset = outerProxy.safeAreaInsets.top
                }
            }
        }
    }
    
    private struct CustomNavigationBar: View {
        let scrollOffset: CGFloat
        let topInset: CGFloat
        
        let defaultHeight = 44.0
        
        var body: some View {
            Color.aiCoBackgroundWhite.opacity(0.5) // .ultraThinMaterial이 너무 어두워 하얀색 섞기
                .ignoresSafeArea()
                .containerRelativeFrame(.horizontal)
                .frame(height: defaultHeight)
                .background(.ultraThinMaterial)
                .overlay(alignment: .center) {
                    Text("대시보드")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.aiCoLabel)
						.offset(y: -5) // 텍스트가 네비게이션바 중앙에 오도록 위치 조정하기
                }
                .overlay(alignment: .bottom) { // 네비게이션바 하단에 구분선 추가하기
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color(.lightGray))
                }
                .opacity(scrollOffset > topInset ? 1 : 0)
                .animation(.easeInOut, value: scrollOffset > topInset)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ThemeManager())
        .environmentObject(RecommendCoinViewModel())
}

/// scrollOffset을 구하기 위한 PreferenceKey
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { .zero }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
