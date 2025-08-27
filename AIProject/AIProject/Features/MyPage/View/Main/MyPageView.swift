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
    @Environment(\.dismiss) var dismiss
    @State private var selection: String? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showMail = false
    @State private var showNoEmailView = false

    var body: some View {
        Group {
            if hSizeClass == .regular {
                // iPad
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    sidebar
                        .toolbar(removing: .sidebarToggle)
                } detail: {
                    NavigationStack {
                        detailView
                    }
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                // iPhone
                NavigationStack {
                    sidebar
                }
            }
        }
        .sheet(isPresented: $showMail) {
            MailView()
        }
        .sheet(isPresented: $showNoEmailView) {
            NoEmailGuideView(showClose: true)
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack {
            HeaderView(heading: "마이페이지")

            VStack(spacing: 16) {
                Group {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("개인화 설정")
                            .fontWeight(.semibold)

                        VStack(spacing: 16) {
                            menuButton("bookmark", title: "북마크 설정", imageName: "bookmark")
                            menuButton("notification", title: "알림 설정", imageName: "bell.badge")
                            menuButton("theme", title: "테마 변경", imageName: "paintpalette")
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("기타 설정")
                            .fontWeight(.semibold)

                        VStack(spacing: 16) {
                            Button {
                                if MFMailComposeViewController.canSendMail() {
                                    showMail = true
                                } else {
                                    if hSizeClass == .regular {
                                        selection = "contact"
                                    } else {
                                        showNoEmailView = true
                                    }
                                }
                            } label: {
                                MyPageMenuRow(title: "문의하기", imageName: "at")
                            }

                            menuButton("privacy", title: "인공지능(AI) 윤리기준", imageName: "sparkles")
                        }
                    }
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.aiCoLabel)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.aiCoBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                )
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - Detail View (iPad)
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case "bookmark":
            BookmarkView()
        case "notification":
            ThemeView()
        case "theme":
            ThemeView()
        case "contact":
            NoEmailGuideView()
        case "privacy":
            PrivacyPolicyView()
        default:
            CommonPlaceholderView(imageName: "logo", text: "메뉴를 선택하세요")
        }
    }

    // MARK: - 메뉴 버튼 (iPad는 selection 변경, iPhone은 NavigationLink)
    @ViewBuilder
    private func menuButton(_ tag: String, title: String, imageName: String) -> some View {
        if hSizeClass == .regular {
            // ipad
            Button {
                selection = tag
            } label: {
                MyPageMenuRow(title: title, imageName: imageName)
            }
        } else {
            // iPhone
            NavigationLink {
                destination(for: tag)
            } label: {
                MyPageMenuRow(title: title, imageName: imageName)
            }
        }
    }

    // MARK: - NavigationLink 목적지
    @ViewBuilder
    private func destination(for tag: String) -> some View {
        switch tag {
        case "bookmark":
            BookmarkView()
        case "notification":
            ThemeView()
        case "theme":
            ThemeView()
        case "privacy":
            PrivacyPolicyView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    MyPageView()
}
