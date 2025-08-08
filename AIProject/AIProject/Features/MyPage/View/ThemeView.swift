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
}

struct ThemeView: View {
    @State private var selectedTheme: Theme = .basic
    
    var body: some View {
        VStack {
            HeaderView(heading: "테마 변경")
                .padding(.top, 20)
                .padding(.bottom, 20)
            SubheaderView(subheading: "차트 색상 변경")
                .padding(.bottom, 20)
            
            ThemeRow(
                title: "기본",
                positiveColor: .aiCoPositive,
                negativecColor: .aiCoNegative,
                isSelected: selectedTheme == .basic
            ) {
                selectedTheme = .basic
            }

            ThemeRow(
                title: "팝",
                positiveColor: .red,
                negativecColor: Color(UIColor.systemMint),
                isSelected: selectedTheme == .pop
            ) {
                selectedTheme = .pop
            }
            
            ThemeRow(
                title: "고전",
                positiveColor: Color(UIColor.systemPink),
                negativecColor: .green,
                isSelected: selectedTheme == .classic
            ) {
                selectedTheme = .classic
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
    let positiveColor: Color
    let negativecColor: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            HStack(spacing: 0) {
                positiveColor
                negativecColor
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
