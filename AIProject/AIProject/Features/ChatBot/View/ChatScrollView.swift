//
//  ChatScrollView.swift
//  AIProject
//
//  Created by 강대훈 on 8/19/25.
//

import SwiftUI

/// 스크롤 오프셋 데이터를 담고있는 PreferenceKey 입니다.
private struct ChatOffSetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

/// `ChatScrollView`는 채팅 화면에서 다음과 같은 기능을 담당하고 처리하는 View입니다.
/// - 새 메시지가 스트리밍/수신될 때, 사용자가 스크롤 바닥 근처에 있는 경우 자동으로 마지막 셀로 스크롤
/// - 사용자가 위로 스크롤해 과거 메시지를 보고 있으면 자동 스크롤을 중단
/// - 레이아웃 변화(키보드, 회전 등) 시 viewport / content 높이 재계산
struct ChatScrollView<Content: View>: View {
    @ObservedObject var viewModel: ChatBotViewModel

    /// 사용자가 드래그 중인지 상태를 기록합니다.
    @GestureState var isDragging: Bool = false

    /// 사용자가 스크롤 바닥 근처에 있는지 상태를 기록합니다.
    @State private var reachToBottom: Bool = true
    @State private var viewportHeight: CGFloat = .zero
    @State private var scrollOffSet: CGFloat = .zero
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
                                    self.contentHeight = geometryProxy.size.height
                                }
                                .onChange(of: contentHeight) {
                                    if reachToBottom && contentHeight > viewportHeight {
                                        scrollProxy.scrollTo(viewModel.messages.last?.id)
                                    }
                                }
                                .onChange(of: viewModel.isReceived) {
                                    if viewModel.isReceived {
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
        .simultaneousGesture(
            DragGesture().updating($isDragging) { drag, state, _ in
                if drag.translation.height > 100 {
                    viewModel.isTapped.toggle()
                }

                state = true
            }
        )
        .contentMargins(.vertical, 16)
        .coordinateSpace(name: coordinateSpaceName)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        viewportHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size.height) { _, newValue in
                        viewportHeight = newValue
                    }
            }
        )
        .onPreferenceChange(ChatOffSetPreferenceKey.self) { value in
            scrollOffSet = value.y
            reachToBottom = contentHeight <= (value.y + viewportHeight + 50) // 50: 스크롤 바닥 근처인지를 확인하는 최소 임계값입니다.
        }
    }
}
