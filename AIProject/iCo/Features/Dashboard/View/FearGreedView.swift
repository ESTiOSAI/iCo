//
//  FearGreedView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 공포-탐욕 지수를 설명과 차트로 시각화하는 메인 뷰입니다.
///
/// 왼쪽에는 지표 설명 텍스트를, 오른쪽에는 `ChartView`를 배치합니다.
struct FearGreedView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: FearGreedViewModel
    
    private static let cornerRadius: CGFloat = 20
    
    init(viewModel: FearGreedViewModel = FearGreedViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("공포 & 탐욕 지수")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.aiCoLabel)
                
                Text("ⓘ Fear & Greed 지수는 투자 심리를 0~100 사이 수치로 나타낸 지표로, 0에 가까울수록 불안감으로 투자를 피하는 '공포', 100에 가까울수록 낙관적으로 적극 매수하는 '탐욕'을 의미합니다.".byCharWrapping)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoLabelSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            ChartView(viewModel: viewModel)
                .frame(width: 90, height: 90)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(viewModel.baseColor.opacity(colorScheme == .dark ? 0.15 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
    }
}

extension FearGreedView {
    /// 공포-탐욕 지수를 원형 차트 형태로 시각화하는 뷰입니다.
    ///
    /// `FearGreedViewModel`에서 제공하는 지수 값과 감정 상태를 기반으로
    /// 반원 형태의 색상 원형 그래프와 텍스트를 표시합니다.
    ///
    /// - indexValue: 공포-탐욕 수치(0~100)
    /// - fearGreed.color: 감정 상태에 따른 색상
    /// - classification: 감정 상태에 대한 설명 텍스트
    fileprivate struct ChartView: View {
        @ObservedObject private var viewModel: FearGreedViewModel
        
        private static let gaugeTrim: CGFloat = 0.75
        private static let lineWidth: CGFloat = 13
        private static let rotationDegrees: Double = 135
        
        init(viewModel: FearGreedViewModel) {
            self._viewModel = ObservedObject(wrappedValue: viewModel)
        }
        
        var body: some View {
            GeometryReader { geometry in
                let size = geometry.size
                
                ZStack {
                    Circle()
                        .trim(from: 0.0, to: Self.gaugeTrim)
                        .stroke(Color.aiCoBackground, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(Self.rotationDegrees))
                    
                    Circle()
                        .trim(from: 0.0, to: Self.gaugeTrim * viewModel.indexValue / 100)
                        .stroke(viewModel.fearGreed.color, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(Self.rotationDegrees))
                    
                    VStack(spacing: size.height * 0.15) {
                        Text("\(Int(viewModel.indexValue))")
                            .font(.system(size: size.width * 0.3, weight: .bold))
                            .foregroundColor(.aiCoLabel)
                            .minimumScaleFactor(0.5)
                        
                        Text(viewModel.classification)
                            .font(.system(size: size.width * 0.15, weight: .semibold))
                            .foregroundStyle(viewModel.fearGreed.color)
                            .padding(.top, size.height * 0.01)
                            .minimumScaleFactor(0.5)
                    }
                    .offset(y: size.height * 0.15)
                }
            }
        }
    }
}

#Preview {
    FearGreedView()
}
