//
//  TabFeature.swift
//  AIProject
//
//  Created by kangho lee on 8/26/25.
//

import SwiftUI

enum TabFeature: String, Hashable, CaseIterable, Identifiable {
    case dashboard = "대시보드"
    case market = "마켓"
    case chatbot = "챗봇"
    case myPage = "마이페이지"
    
    var icon: String {
        switch self {
        case .dashboard:
            return "square.grid.2x2"
        case .market:
            return "bitcoinsign.bank.building"
        case .chatbot:
            return "bubble.left.and.text.bubble.right"
        case .myPage:
            return "person.crop.circle"
        }
    }
    
    var id: String {
        return rawValue
    }
}
