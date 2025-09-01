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
    
    @State var isLandscape: Bool = false

    var body: some View {
        GeometryReader { proxy in
            TabView {
                ForEach(1 ... 4, id: \.self) { i in
                    OnboardingPageView(imageName: "onboarding-\(i)", isLandscape: $isLandscape)
                        .padding(.bottom, 32)
                        .padding(.horizontal, .spacing)
                }
                
                LastOnboardingPage(isLandscape: $isLandscape) {
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
            .onAppear {
                isLandscape = proxy.size.width > proxy.size.height
            }
        }
    }
}

#Preview {
    OnboardingView()
}

enum OnboardingConst {
    static let maxWidth: CGFloat = 500
    static let maxHeight: CGFloat = 700
}
