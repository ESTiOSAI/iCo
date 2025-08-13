//
//  SortToggleButton.swift
//  AIProject
//
//  Created by 백현진 on 8/4/25.
//

import SwiftUI

enum SortCategory {
    case name
//    case price
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
        case .none: return "minus"
        case .ascending: return "chevron.up"
        case .descending: return "chevron.down"
        }
    }
}

struct SortToggleButton: View {
    let title: String
    let sortCategory: SortCategory
    @Binding var currentCategory: SortCategory?
    @Binding var sortOrder: SortOrder

    var body: some View {

        HStack {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoLabel)
            RoundedButton(imageName: sortOrder.iconName) {
                if currentCategory == sortCategory {
                    sortOrder.toggle()
                } else {
                    sortOrder = .ascending
                }

                currentCategory = sortCategory
            }
        }
    }
}
