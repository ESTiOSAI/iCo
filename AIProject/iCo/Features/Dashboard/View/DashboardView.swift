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
    @State var scrollOffset: CGFloat = 0
    @State var topInset: CGFloat = 0
    
    var gradientHeight: CGFloat {
        CardConst.headerHeight + CardConst.headerContentSpacing + (CardConst.cardHeight / 2) + topInset
    }
    
    var body: some View {
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
                    if hSizeClass == .compact {
                        let defaultHeight = 44.0
                        
                        Color.aiCoBackgroundWhite.opacity(0.5) // .ultraThinMaterial이 너무 어두워 하얀색 섞기
                            .ignoresSafeArea()
                            .containerRelativeFrame(.horizontal)
                            .frame(height: defaultHeight)
                            .background(.ultraThinMaterial)
                            .overlay(alignment: .center) {
                                Text("대시보드")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.aiCoLabel)
                                    .offset(y: -5) // 텍스트가 네비게이션바 중앙에 오도록 위치 조정하기
                            }
                            .overlay(alignment: .bottom) { // 헤더 하단에 구분선 추가하기
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
            .onAppear {
                topInset = outerProxy.safeAreaInsets.top
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ThemeManager())
        .environmentObject(RecommendCoinViewModel())
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { .zero }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
