//
//  DashboardSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

struct DashboardSectionView<Content: View>: View {
    let subheading: String
    var description: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            SubheaderView(subheading: subheading, description: description)
            content()
        }
        .padding(.bottom, 40
        )
    }
}

#Preview {
    DashboardSectionView(subheading: "title", description: "description") {
        EmptyView()
    }
}
