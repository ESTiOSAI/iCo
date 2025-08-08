//
//  ThemeManager.swift
//  AIProject
//
//  Created by 강민지 on 8/8/25.
//

import SwiftUI

/// 테마 설정을 관리하는 전역 상태 객체
class ThemeManager: ObservableObject {
    /// 현재 선택된 테마
    /// 값이 변경될 때마다 `UserDefaults`에 자동으로 저장
    @Published var selectedTheme: Theme {
        didSet {
            saveTheme()
        }
    }
    
    /// UserDefaults에 저장할 키 값
    private let themeKey = "selectedTheme"
    
    /// 초기화 시 저장된 테마 값을 UserDefaults에서 불러와 설정
    /// 저장된 값이 없거나 변환에 실패할 경우 기본 테마인 `.basic`을 사용
    init() {
        if let saved = UserDefaults.standard.string(forKey: themeKey),
           let theme = Theme(rawValue: saved) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .basic
        }
    }
    
    /// 선택된 테마를 UserDefaults에 저장
    private func saveTheme() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
    }
}
