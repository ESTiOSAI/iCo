//
//  MyPageMenu.swift
//  AIProject
//
//  Created by kangho lee on 8/30/25.
//

import Foundation

enum MyPageMenu: String, Hashable, Identifiable {
    case bookmark
    case updateRiskTolerance
    case themeSet
    case feedback
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .bookmark: return "북마크 관리"
        case .updateRiskTolerance: return "투자 성향 변경"
        case .themeSet: return "테마 변경"
        case .feedback: return "이메일 문의"
        }
    }
    
    var icon: String {
        switch self {
        case .bookmark: return "bookmark"
        case .updateRiskTolerance: return "dial.medium"
        case .themeSet: return "paintpalette"
        case .feedback: return "at"
        }
    }
}
