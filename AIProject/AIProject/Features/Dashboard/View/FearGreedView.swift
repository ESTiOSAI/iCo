//
//  FearGreedView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI


/// 공포-탐욕 지수를 원형 차트 형태로 시각화하는 뷰입니다.
///
/// `FearGreedViewModel`에서 제공하는 지수 값과 감정 상태를 기반으로
/// 반원 형태의 색상 원형 그래프와 텍스트를 표시합니다.
///
/// - indexValue: 공포-탐욕 수치(0~100)
/// - fearGreed.color: 감정 상태에 따른 색상
/// - classification: 감정 상태에 대한 설명 텍스트
struct FearGreedView: View {
    @StateObject var viewModel: FearGreedViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FearGreedViewModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color.aiCoBackground, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                Circle()
                    .trim(from: 0.0, to: 0.75 * viewModel.indexValue / 100)
                    .stroke(viewModel.fearGreed.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                VStack(spacing: size.height * 0.15) {
                    Text("\(Int(viewModel.indexValue))")
                        .font(.system(size: size.width * 0.3, weight: .bold))
                        .foregroundColor(.aiCoLabel)
                    
                    Text(viewModel.classification)
                        .font(.system(size: size.width * 0.15, weight: .semibold))
                        .foregroundStyle(viewModel.fearGreed.color)
                        .padding(.top, size.height * 0.01)
                }
                .offset(y: size.height * 0.15)
            }
        }
        .frame(width: 120, height: 120)
    }
}

#Preview {
    FearGreedView()
}
