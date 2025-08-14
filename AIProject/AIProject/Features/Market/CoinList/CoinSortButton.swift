//
//  CoinSortButton.swift
//  AIProject
//
//  Created by kangho lee on 8/13/25.
//

import SwiftUI
struct SortToggleButton2: View {
    let title: String
    let sortCategory: SortCategory
    
    @Binding var sortOrder: SortOrder
    
    let action: () -> Void

    var body: some View {
        Button {
            action()
            sortOrder = sortOrder == .ascending ? .descending : .ascending
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoLabelSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: sortOrder.iconName)
                        .font(.system(size: 10))
                        .foregroundStyle(.aiCoLabelSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(width: 24, height: 24)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .overlay {
                    Capsule()
                        .stroke(.default, lineWidth: 0.5)
                }
            }
            .fontWeight(sortOrder != .none ? .bold : .regular)
        }
        .buttonStyle(.plain)
    }
}
