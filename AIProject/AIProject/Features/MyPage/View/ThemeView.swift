//
//  ThemeView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme = .basic
}

enum Theme: String, CaseIterable {
    case basic
    case pop
    case classic
    
    var positiveColor: Color {
        switch self {
        case .basic: return .aiCoPositive
        case .pop: return .red
        case .classic: return Color(UIColor.systemPink)
        }
    }
    
    var negativeColor: Color {
        switch self {
        case .basic: return .aiCoNegative
        case .pop: return Color(UIColor.systemMint)
        case .classic: return .green
        }
    }
}

struct ThemeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            HeaderView(heading: "테마 변경")
                .padding(.top, 20)
                .padding(.bottom, 20)
            SubheaderView(subheading: "차트 색상 변경")
                .padding(.bottom, 20)
            
            ThemeRow(
                title: "기본",
                theme: .basic,
                isSelected: themeManager.selectedTheme == .basic
            ) {
                themeManager.selectedTheme = .basic
            }

            ThemeRow(
                title: "팝",
                theme: .pop,
                isSelected: themeManager.selectedTheme == .pop
            ) {
                themeManager.selectedTheme = .pop
            }
            
            ThemeRow(
                title: "고전",
                theme: .classic,
                isSelected: themeManager.selectedTheme == .classic
            ) {
                themeManager.selectedTheme = .classic
            }
            
            Spacer()
        }
    }
}

#Preview {
    ThemeView()
}

struct ThemeRow: View {
    let title: String
    let theme: Theme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            HStack(spacing: 0) {
                theme.positiveColor
                theme.negativeColor
            }
            .frame(width: 40, height: 20)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue.opacity(0.1) : .aiCoBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue.opacity(0.1) : .aiCoBackground, lineWidth: 1)
        }
        .onTapGesture {
            onTap()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}
