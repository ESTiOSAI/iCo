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
    @Environment(\.verticalSizeClass) var vSizeClass
    @State private var selection: String? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showMail = false

    var body: some View {
        if hSizeClass == .regular && vSizeClass == .regular {
            // iPad
            NavigationSplitView(columnVisibility: $columnVisibility) {
                sidebar
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
            .sheet(isPresented: $showMail) {
                MailView()
            }
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
                            if hSizeClass == .regular && vSizeClass == .regular {
                                Button {
                                    selection = "contact"
                                } label: {
                                    MyPageMenuRow(title: "문의하기", imageName: "at")
                                }
                            } else {
                                Button {
                                    if MFMailComposeViewController.canSendMail() {
                                        showMail = true
                                    }
                                } label: {
                                    MyPageMenuRow(title: "문의하기", imageName: "at")
                                }
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
                        .stroke(.defaultGradient, lineWidth: 0.5)
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
            if MFMailComposeViewController.canSendMail() {
                MailView()
            } else {
                VStack(spacing: 12) {
                    Text("메일 계정을 설정해야 메일을 보낼 수 있습니다.")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundStyle(.aiCoLabelSecondary)
                    Text("설정 > Mail 앱에서 계정을 추가하세요.")
                        .font(.system(size: 18))
                        .foregroundStyle(.aiCoNeutral)
                }
                .padding()
            }
        case "privacy":
            PrivacyPolicyView()
        default:
            Text("왼쪽에서 메뉴를 선택하세요")
                .foregroundStyle(.aiCoLabelSecondary)
        }
    }

    // MARK: - 메뉴 버튼 (iPad는 selection 변경, iPhone은 NavigationLink)
    @ViewBuilder
    private func menuButton(_ tag: String, title: String, imageName: String) -> some View {
        if hSizeClass == .regular && vSizeClass == .regular {
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
