//
//  UpdateRiskToleranceView.swift
//  iCo
//
//  Created by 지현 on 10/21/25.
//

import SwiftUI

struct UpdateRiskToleranceView: View {
    @AppStorage(AppStorageKey.investmentType) private var storedInvestmentType: String = ""
    @State private var selectedType: RiskTolerance?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SubheaderView(subheading: "나의 투자 성향 조정")
                    .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    ForEach(RiskTolerance.allCases, id: \.self) { type in
                        RoundedRectangleFillButton(title: type.rawValue,
                                                   isHighlighted: Binding(get: { storedInvestmentType == type.rawValue }, set: { _ in })) {
                            withAnimation(.snappy) { storedInvestmentType = type.rawValue }
                        }
                    }
                }
                .padding(.horizontal, .spacing)
            }
        }
        .interactiveSwipeBackEnabled()
        .scrollIndicators(.hidden)
    }
}

#Preview {
    UpdateRiskToleranceView()
}
