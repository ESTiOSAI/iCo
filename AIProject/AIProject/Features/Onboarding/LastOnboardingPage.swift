//
//  LastOnboardingPage.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct LastOnboardingPage: View {
    @State private var selectedType: RiskTolerance?
    @State var isSelected = false
    var onFinish: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HeaderView(heading: "나의 투자 성향 고르기")
                .padding(.bottom, 16)
            
            SubheaderView(subheading: "아래 5가지 중 본인에게 맞는\n투자 성향을 선택해주세요.", description: "투자 성향은 추후 추천 콘텐츠와 서비스에 반영됩니다.")
                .padding(.bottom, 16)
            
            ForEach(RiskTolerance.allCases, id: \.self) { type in
                RoundedRectangleFillButton(
                    title: type.rawValue,
                    isSelected: Binding(get: { selectedType == type }, set: { _ in })) {
                        selectedType = type
                        isSelected = true
                    }
                    .animation(.easeInOut(duration: 0.15), value: selectedType)
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            RoundedRectangleFillButton(title: "시작하기", isSelected: $isSelected) {
                if let selected = selectedType {
                    UserDefaults.standard.set(selected.rawValue, forKey: UserDefaults.Keys.investmentType)
                    
                    let savedValue = UserDefaults.standard.string(forKey: UserDefaults.Keys.investmentType)
                    print("저장된 투자 성향: \(savedValue ?? "없음")")
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
