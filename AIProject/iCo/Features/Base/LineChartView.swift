//
//  LineChartView.swift
//  iCo
//
//  Created by 백현진 on 10/24/25.
//

import SwiftUI

/// 공통으로 사용할 수 있는 라인 차트(미니 차트) 컴포넌트
struct LineChartView: View {
    /// 차트에 표시할 값 목록 (예: 가격 데이터)
    let values: [Double]
    
    /// 차트 선 색상 (기본값: aiCoAccent)
    var lineColor: Color = .iCoAccent
    
    /// 마지막 지점 표시 여부
    var showsLastDot: Bool = true
    
    /// 선 두께
    var lineWidth: CGFloat = 2
    
    /// 내부 계산용 정규화된 값
    private var normalizedValues: [CGFloat] {
        guard values.count > 1 else { return [] }
        guard let min = values.min(), let max = values.max(), min != max else {
            return Array(repeating: 0.5, count: values.count)
        }
        return values.map { CGFloat(($0 - min) / (max - min)) }
    }

    var body: some View {
        GeometryReader { geo in
            if normalizedValues.isEmpty {
                // 값이 없을 때 — 가운데 회색 선 표시
                Path { path in
                    let midY = geo.size.height / 2
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: geo.size.width, y: midY))
                }
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            } else {
                ZStack {
                    // 스파크라인
                    Path { path in
                        for (index, value) in normalizedValues.enumerated() {
                            let x = geo.size.width * CGFloat(index) / CGFloat(normalizedValues.count - 1)
                            let y = geo.size.height * (1 - value)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                    
                    // 마지막 점
                    if showsLastDot, let last = normalizedValues.last {
                        let x = geo.size.width
                        let y = geo.size.height * (1 - last)

                        Circle()
                            .fill(lineColor)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

