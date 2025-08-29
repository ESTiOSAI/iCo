//
//  LastOnboardingPage.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct LastOnboardingPage: View {
    @EnvironmentObject var recommendCoinViewModel: RecommendCoinViewModel
    
    @AppStorage(AppStorageKey.investmentType) private var storedInvestmentType: String = ""
    
    @State private var selectedType: RiskTolerance?

    var onFinish: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HeaderView(heading: "나의 투자 성향 고르기")
                .padding(.bottom, 16)
            
            SubheaderView(subheading: "아래에서 투자 성향을 선택해주세요", description: "앞으로 제공해드릴 추천 콘텐츠와 서비스에 반영돼요")
                .padding(.bottom, 16)
            
            ForEach(RiskTolerance.allCases, id: \.self) { type in
                RoundedRectangleFillButton(
                    title: type.rawValue,
                    isHighlighted: Binding(get: { selectedType == type }, set: { _ in })) {
                        withAnimation(.snappy) {
                                selectedType = type
                            }
                    }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            RoundedRectangleFillButton(
                title: "시작하기",
                isHighlighted: .init(get: { selectedType != nil }, set: { _ in })
            ) {
                if let selected = selectedType {
                    storedInvestmentType = selected.rawValue
                    
                    print("저장된 투자 성향: \(storedInvestmentType.isEmpty ? "없음" : storedInvestmentType)")
                    recommendCoinViewModel.loadRecommendCoin(selectedPreference: storedInvestmentType)
                }
                onFinish()
            }
            .disabled(selectedType == nil)
            .opacity(selectedType == nil ? 0.5 : 1)
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

#Preview {
    LastOnboardingPage(onFinish: dummyAction )
        .environmentObject(RecommendCoinViewModel())
}
