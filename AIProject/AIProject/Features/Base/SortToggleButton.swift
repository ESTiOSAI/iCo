//
//  SortToggleButton.swift
//  AIProject
//
//  Created by 백현진 on 8/4/25.
//

import SwiftUI

enum SortCategory {
    case name
    case price
    case volume
}

enum SortOrder {
    /// 기본 상태
    case none
    /// 오름 차순
    case ascending
    /// 내림 차순
    case descending

    mutating func toggle() {
        switch self {
        case .none: self = .ascending
        case .ascending: self = .descending
        case .descending: self = .none
        }
    }

    var iconName: String {
        switch self {
        case .none: return "arrow.up.arrow.down"
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        }
    }
}

struct SortToggleButton: View {
    let title: String
    let sortCategory: SortCategory
    @Binding var currentCategory: SortCategory?
    @Binding var sortOrder: SortOrder

    var body: some View {
        Button {
            if currentCategory == sortCategory {
                sortOrder.toggle()
            } else {
                sortOrder = .ascending
            }

            currentCategory = sortCategory
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoLabel)
                Image(systemName: sortOrder.iconName)
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(sortOrder == .none ? .aiCoLabelSecondary : .aiCoLabel)
            }
        }
        .buttonStyle(.plain)
    }
}
