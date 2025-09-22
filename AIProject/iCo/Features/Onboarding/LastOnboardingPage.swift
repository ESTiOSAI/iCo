//
//  LastOnboardingPage.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

/// 온보딩 마지막 단계에서 투자 성향을 선택하는 화면입니다.
///
/// 사용자가 보수적/중립적/공격적 등의 투자 성향(`RiskTolerance`)을 선택하면
/// 해당 값이 `AppStorage`에 저장되고, 추천 코인 데이터 로딩에 반영됩니다.
///
/// - Properties:
///   - recommendCoinViewModel: 추천 코인 데이터를 관리하는 뷰모델(`EnvironmentObject`)
///   - storedInvestmentType: 선택된 투자 성향을 `AppStorage`에 저장
///   - selectedType: 현재 사용자가 선택한 투자 성향 상태
///   - isLandscape: 가로/세로 레이아웃 여부를 나타내는 바인딩 값
///   - onFinish: 온보딩 완료 시 호출되는 콜백
struct LastOnboardingPage: View {
    @EnvironmentObject var recommendCoinViewModel: RecommendCoinViewModel
    
    @AppStorage(AppStorageKey.investmentType) private var storedInvestmentType: String = ""
    
    @State private var selectedType: RiskTolerance?
    @Binding var isLandscape: Bool
    
    var onFinish: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                HeaderView(heading: "나의 투자 성향 고르기")
                
                SubheaderView(subheading: "아래에서 투자 성향을 선택해주세요", description: "앞으로 제공해드릴 추천 콘텐츠와 서비스에 반영돼요")
                    .padding(.bottom, .spacing)
                
                ForEach(RiskTolerance.allCases, id: \.self) { type in
                    RoundedRectangleFillButton(
                        title: type.rawValue,
                        isHighlighted: Binding(get: { selectedType == type }, set: { _ in })) {
                            withAnimation(.snappy) {
                                selectedType = type
                            }
                        }
                }
                .padding(.horizontal, .spacing)
                
                Spacer()
                    .frame(minHeight: 60)
                
                RoundedRectangleFillButton(
                    title: "시작하기",
                    isHighlighted: .init(get: { selectedType != nil }, set: { _ in })
                ) {
                    if let selected = selectedType {
                        storedInvestmentType = selected.rawValue
                    }
                    onFinish()
                }
                .disabled(selectedType == nil)
                .opacity(selectedType == nil ? 0.5 : 1)
                .padding(.horizontal, .spacing)
                .padding(.bottom, 30)
            }
        }
        .frame(
            maxWidth: OnboardingConst.maxWidth,
            maxHeight: isLandscape ? nil : OnboardingConst.maxHeight
        )
    }
}

#Preview {
    LastOnboardingPage(isLandscape: .constant(true), onFinish: { })
        .environmentObject(RecommendCoinViewModel())
}
