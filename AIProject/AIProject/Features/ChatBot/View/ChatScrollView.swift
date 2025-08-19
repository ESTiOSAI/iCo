//
//  ChatScrollView.swift
//  AIProject
//
//  Created by 강대훈 on 8/19/25.
//

import SwiftUI

private struct ChatOffSetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ChatScrollView<Content: View>: View {
    @ObservedObject var viewModel: ChatBotViewModel

    @State private var reachToBottom: Bool = true
    @State private var viewportHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = .zero
    @Namespace private var coordinateSpaceName: Namespace.ID
    @ViewBuilder private var content: () -> Content

    init(
        viewModel: ChatBotViewModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.viewModel = viewModel
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ScrollViewReader { scrollProxy in
                content()
                    .background {
                        GeometryReader { geometryProxy in
                            Color.clear
                                .onAppear {
                                    let contentHeight = geometryProxy.size.height
                                    self.contentHeight = contentHeight
                                }
                                .onChange(of: viewModel.messages.last?.id) {
                                    let contentHeight = geometryProxy.size.height
                                    self.contentHeight = contentHeight

                                    if reachToBottom {
                                        scrollProxy.scrollTo(viewModel.messages.last?.id)
                                    }
                                }
                                .preference(
                                    key: ChatOffSetPreferenceKey.self,
                                    value: CGPoint(
                                        x: -geometryProxy.frame(in: .named(coordinateSpaceName)).minX,
                                        y: -geometryProxy.frame(in: .named(coordinateSpaceName)).minY
                                    )
                                )
                        }
                    }
            }
        }
        .contentMargins(.vertical, 16)
        .coordinateSpace(name: coordinateSpaceName)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        viewportHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size.height) {
                        viewportHeight = $0
                    }
            }
        )
        .onPreferenceChange(ChatOffSetPreferenceKey.self) { value in
            print("Scroll")
            reachToBottom = contentHeight <= (value.y + viewportHeight + 50) // 50: 최소 임계값
        }
    }
}
