//
//  TopBannerView.swift
//  iCo
//
//  Created by Kanghos on 9/18/25.
//

import SwiftUI

struct TopBannerView: View {
    @Bindable var controller: TopBannerController

    var body: some View {
        if controller.isVisible {
            HStack(spacing: 8) {
                Image(systemName: controller.kind == .offline ? "wifi.slash" : "wifi")
                    .font(.headline)
                Text(controller.message)
                    .font(.subheadline).bold()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(background)
            .overlay(Divider(), alignment: .bottom)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.snappy, value: controller.isVisible)
        }
    }

    private var background: some View {
        Group {
            switch controller.kind {
            case .offline:
                Color.red.opacity(0.95)
            case .online:
                Color.green.opacity(0.95)
            }
        }
        .ignoresSafeArea(edges: .top) // 상태바까지 꽉 차게
    }
}
