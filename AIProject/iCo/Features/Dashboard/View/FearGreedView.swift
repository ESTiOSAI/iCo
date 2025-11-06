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
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @StateObject private var viewModel: FearGreedViewModel = FearGreedViewModel()
    @State private var showFearGreedDescription: Bool = false
    
    private static let cornerRadius: CGFloat = 20
    private var chartWidth: CGFloat {
        let baseWidth: CGFloat = 110
        
        switch typeSize {
        case .xSmall, .small, .medium, .large:
            return baseWidth
        case .xLarge, .xxLarge, .xxxLarge:
            return baseWidth * 0.9
        default:
            return baseWidth * 0.7
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                headerSection
                
                Spacer()
                
                chartSection
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            if showFearGreedDescription {
                fearGreedDescription
                    .opacity(!showFearGreedDescription ? 0 : 1)
                    .animation(.snappy(duration: 0.3), value: showFearGreedDescription)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(viewModel.baseColor.opacity(colorScheme == .dark ? 0.15 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
        .animation(.snappy(duration: 0.2), value: showFearGreedDescription)
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if hSizeClass == .compact {
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text("지금 시장은")
                        
                        Text(viewModel.classification)
                            .foregroundStyle(viewModel.fearGreed.color)
                            
                        + Text(" 상태예요")
                    }
                    .font(.ico18B)
                    .foregroundStyle(.iCoLabel)
                }
            } else {
                HStack(spacing: 4) {
                    Group {
                        Text("지금 시장은")
                        
                        Text(viewModel.classification)
                            .foregroundStyle(viewModel.fearGreed.color)
                        
                        + Text(" 상태예요")
                    }
                    .font(.ico18B)
                    .foregroundStyle(.iCoLabel)
                }
            }
            
            if hSizeClass == .compact {
                RoundedButton(title: "공포 탐욕 지수란?", imageName: "chevron.down", rotatingAnimation: true) {
                    showFearGreedDescription.toggle()
                }
                .fixedSize(horizontal: true, vertical: false)
                .padding(.top, 8)
                .offset(x: -4)
            } else {
                fearGreedDescription
            }
        }
    }
    
    var chartSection: some View {
        HStack(alignment: .bottom, spacing: .spacingSmall) {
            Group {
                Text("0")
                    .offset(y: 4)
                
                ChartView(viewModel: viewModel, chartWidth: chartWidth)
                    .frame(width: chartWidth, height: chartWidth / 2)
                
                Text("100")
                    .offset(y: 6)
            }
            .font(.ico12M)
            .foregroundStyle(.secondary)
        }
    }
    
    var fearGreedDescription: some View {
        Text("ⓘ 공포 탐욕 지수는 투자 심리를 0~100 사이 수치로 나타낸 지표로, 0에 가까울수록 불안감으로 투자를 피하는 '공포', 100에 가까울수록 낙관적으로 적극 매수하는 '탐욕'을 의미합니다.".byCharWrapping)
            .font(.ico13)
            .padding(.top, 4)
            .foregroundStyle(.iCoNeutral)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
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
        
        private static let gaugeTrim: CGFloat = 0.5
        private static let lineWidth: CGFloat = 10
        private static let rotationDegrees: Double = 180
        @State private var guageValue: CGFloat
        
        let chartWidth: CGFloat
        let chartHeight: CGFloat
        
        init(viewModel: FearGreedViewModel, chartWidth: CGFloat) {
            self._viewModel = ObservedObject(wrappedValue: viewModel)
            self.chartWidth = chartWidth
            self.chartHeight = chartWidth / 2
            self.guageValue = viewModel.indexValue
        }
        
        var body: some View {
            ZStack {
                // 배경
                Circle()
                    .trim(from: 0.0, to: Self.gaugeTrim)
                    .stroke(Color(uiColor: UIColor.systemBackground),
                            style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(Self.rotationDegrees))
                    .frame(height: chartHeight * 2)
                    .shadow(color: .black.opacity(0.15), radius: 5)
                
                // 실제 게이지
                Circle()
                    .trim(from: 0.0, to: Self.gaugeTrim * (guageValue / 100))
                    .stroke(
                        LinearGradient(
                            colors: [FearGreed.extremeFear.color, FearGreed.neutral.color, FearGreed.extremeGreed.color],
                            startPoint: .trailing,
                            endPoint: .leading
                        ),
                        style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(Self.rotationDegrees))
                    .frame(height: chartHeight * 2)
                    .animation(.snappy, value: guageValue)
                
                Text(guageValue, format: .number)
                    .font(.dynamic(size: chartWidth / 5))
                    .bold()
                    .foregroundColor(.iCoLabel)
                    .offset(y: -chartHeight * 0.2)
                    .animation(.snappy, value: guageValue)
                    .contentTransition(.numericText(countsDown: true))
            }
            .offset(y: chartHeight / 2)
            .onChange(of: viewModel.indexValue) { _, newValue in
                Task {
                    try await Task.sleep(for: .seconds(0.5))
                    guageValue = newValue
                }
            }
        }
    }
}

#Preview {
    FearGreedView()
        .environmentObject(ThemeManager())
        .padding(16)
    
    Spacer()
}
