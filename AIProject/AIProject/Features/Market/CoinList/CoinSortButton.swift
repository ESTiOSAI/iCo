//
//  CoinSortButton.swift
//  AIProject
//
//  Created by kangho lee on 8/13/25.
//

import SwiftUI

struct CoinSortButton: View {
    let title: String
    let sortCategory: SortCategory
    @Binding var currentCategory: SortCategory?
    @Binding var sortOrder: SortOrder
    
    @ViewBuilder
    func makeSymbol() -> some View {
        switch sortOrder {
        case .ascending:
            Image(systemName: "chevron.up")
                .font(.system(size: 10))
        case .descending:
            Image(systemName: "chevron.down")
                .font(.system(size: 10))
        default:
            Text("—")
                .fontWeight(.medium)
                .font(.system(size: 12))
        }
    }

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
                    .font(.system(size: 12))
                    .fontWeight(currentCategory == sortCategory ? .bold : .regular)
                    .foregroundStyle(.aiCoLabelSecondary)
                makeSymbol()
                    .foregroundStyle(.aiCoLabel)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .overlay {
                        Capsule()
                            .stroke(.default, lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
