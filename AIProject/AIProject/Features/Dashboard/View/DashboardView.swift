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
    
    var tempPadding: CGFloat {
        hSizeClass == .regular ? 70 : 50
    }
    
    var threshold: CGFloat {
        hSizeClass == .regular ? 120 : 80
    }
    
    var gradientHeight: CGFloat {
        CardConst.headerHeight + CardConst.headerContentSpacing + (CardConst.cardHeight / 2) + tempPadding
    }
    
    var body: some View {
        let extra = max(0, -scrollOffset * 0.8)
        
        NavigationStack {
            ScrollView {
                    VStack {
                        RecommendCoinView()
                        AIBriefingView()
                    }
                    .padding(.top, tempPadding)
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
                .frame(height: gradientHeight + extra)
                .offset(y: scrollOffset < threshold ? 0 : -scrollOffset)
                .animation(.easeInOut, value: scrollOffset)
                .ignoresSafeArea(edges: .top)
            }
            .ignoresSafeArea(edges: .top)
            .safeAreaInset(edge: .top) {
                if hSizeClass == .compact {
                    let defaultHeight = 44.0
                    
                    Rectangle()
                        .ignoresSafeArea()
                        .containerRelativeFrame(.horizontal)
                        .frame(height: defaultHeight)
                        .foregroundStyle(.ultraThinMaterial)
                        .overlay(alignment: .center) {
                            Text("대시보드")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(.aiCoLabel)
                        }
                        .opacity(scrollOffset > threshold ? 1 : 0)
                        .animation(.snappy(duration: 0.2), value: scrollOffset > threshold)
                        .allowsHitTesting(false)
                }
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
