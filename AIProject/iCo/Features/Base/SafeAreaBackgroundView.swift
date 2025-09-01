//
//  SafeAreaBackgroundView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/28/25.
//

import SwiftUI

struct SafeAreaBackgroundView: View {
    var body: some View {
        Rectangle()
            .fill(.background)
            .frame(height: 70)
            .ignoresSafeArea()
    }
}
