//
//  MyPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI
import MessageUI

struct MyPageView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(CoinStore.self) var coinStore
    @State private var selection: MyPageMenu? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showMail = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .toolbar(removing: .sidebarToggle)
                .toolbar(.hidden, for: .navigationBar)
        } detail: {
            if let selection {
                NavigationStack {
                    VStack(spacing: 0) {
                        HeaderView(
                            heading: selection.title,
                            showBackButton: hSizeClass == .compact,
                            onBackButtonTap: { self.selection = nil }
                        )
                        switch selection {
                        case .bookmark:
                            BookmarkView(coinStore: coinStore)
                        case .themeSet:
                            ThemeView()
                        case .feedback:
                            NoEmailGuideView()
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
            } else {
                CommonPlaceholderView(imageName: "logo", text: "메뉴를 선택하세요")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showMail) {
            MailView()
        }
    }
    
    // MARK: - Sidebar
    private var sidebar: some View {
        VStack {
            HeaderView(heading: "마이페이지")
            
            List(selection: $selection) {
                VStack {
                    Section {
                        ForEach([MyPageMenu.bookmark, .themeSet]) { menu in
                            MyPageMenuRow(title: menu.title, imageName: menu.icon)
                                .contentShape(.rect)
                                .onTapGesture {
                                    selection = menu
                                }
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSpacing(16)
                    } header: {
                        HStack {
                            Text("개인화 설정")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.aiCoBackground)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                )
                .listRowSeparator(.hidden)
                
                VStack {
                    Section {
                        ForEach([MyPageMenu.feedback]) { menu in
                            MyPageMenuRow(title: menu.title, imageName: menu.icon)
                                .contentShape(.rect)
                                .onTapGesture {
                                    if MFMailComposeViewController.canSendMail() {
                                        showMail = true
                                    } else {
                                        selection = menu
                                    }
                                }
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSpacing(16)
                    } header: {
                        HStack {
                            Text("기타 메뉴")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.aiCoBackground)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                )
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    MyPageView()
}
