//
//  OnBoardingView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        TabView {
            OnboardingPageView()
            OnboardingPageView()
            LastOnboardingPage {
                withAnimation {
                    hasSeenOnboarding = true
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .task {
            await vm.loadCoinImages()
        }
    }
}

#Preview {
    OnboardingView()
}
