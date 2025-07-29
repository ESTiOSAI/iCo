//
//  OnBoardingView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct OnboardingView: View {
  @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
  
    var body: some View {
      TabView {
        OnboardingPageVIew()
        OnboardingPageVIew()
        LastOnboardingPage {
          withAnimation {
            hasSeenOnboarding = true
          }
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
      .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

#Preview {
    OnboardingView()
}
