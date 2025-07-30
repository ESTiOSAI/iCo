//
//  LastOnboardingPage.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct LastOnboardingPage: View {
    var onFinish: () -> Void
    
    var body: some View {
        VStack {
            Text("시작해볼까요?")
                .font(.title)
            
            Button("시작하기") {
                onFinish()
            }
            .padding()
        }
    }
}
