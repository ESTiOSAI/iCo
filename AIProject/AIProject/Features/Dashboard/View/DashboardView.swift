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
        
        NavigationStack {
            ScrollView {
                    VStack {
                        RecommendCoinView()
                        AIBriefingView()
                    }
                    .padding(.top, tempPadding)
                    .background(alignment: .top, content: {
                        LinearGradient(
                            colors: [.aiCoBackgroundGradientLight, .aiCoBackgroundGradientProminent],
                            startPoint: .topLeading,
                            endPoint: .bottom
                        )
                        .frame(height: gradientHeight)
                    })
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: -proxy.frame(in: .named(coordinateSpaceName)).minY
                                )
                        }
                    }
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .overlay(alignment: .top) {
                if hSizeClass == .compact {
                    VStack {
                        Rectangle()
                            .frame(height: 80)
                            .containerRelativeFrame(.horizontal)
                            .foregroundStyle(.ultraThinMaterial)
                            .overlay(alignment: .bottom) {
                                Text("대시보드")
                                    .font(.system(size: 18, weight: .black))
                                    .padding(.bottom)
                            }
                    }
                    .opacity(scrollOffset > threshold ? 1 : 0)
                }
            }
            .ignoresSafeArea(edges: .top)
            
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
