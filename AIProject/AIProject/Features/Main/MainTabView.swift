//
//  MainTabView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "pencil") {
                DashboardView()
            }
            
            Tab("News", systemImage: "pencil") {
                NewsView()
            }
            
            Tab("ChatBot", systemImage: "pencil") {
                ChatBotView()
            }
            
            Tab("MyPage", systemImage: "pencil") {
                MyPageView()
            }
        }
    }
}
