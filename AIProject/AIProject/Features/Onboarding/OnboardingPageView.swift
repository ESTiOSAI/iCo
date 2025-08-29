//
//  OnboardingPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct OnboardingPageView: View {
    var imageName: String
    @Binding var isLandscape: Bool
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: OnboardingConst.maxWidth,
                    maxHeight: isLandscape ? OnboardingConst.maxHeight : .infinity
                )
        }
    }
}
#Preview {
    OnboardingPageView(imageName: "onboarding-1", isLandscape: .constant(true))
}
