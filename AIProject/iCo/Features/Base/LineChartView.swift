//
//  LineChartView.swift
//  iCo
//
//  Created by 백현진 on 10/24/25.
//

import SwiftUI
import Charts

/// 공통으로 사용할 수 있는 라인 차트(미니 차트) 컴포넌트
///
/// - Parameters:
///   - values: 차트에 표시할 값 목록 (예: 가격 데이터)
///   - lineColor: 차트 선 색상 (기본값은 `Color.iCoAccent`)
///   - lineWidth: 선의 두께 (기본값: `2`)
struct LineChartView: View {
    let values: [Double]
    var lineColor: Color = .iCoAccent
    var lineWidth: CGFloat = 2

    var body: some View {
        if values.isEmpty {
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            let normalizedData = values.map { ($0 / (values.first ?? 1.0)) - 1.0 }

            Chart {
                ForEach(Array(normalizedData.enumerated()), id: \.offset) {
                    index,
                    value in
                    LineMark(
                        x: .value("Index", Double(index)),
                        y: .value("Change", value)
                    )
                    .foregroundStyle(lineColor)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Index", Double(index)),
                        y: .value("Change", value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [lineColor.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
    }
}
