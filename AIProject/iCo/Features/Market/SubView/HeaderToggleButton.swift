//
//  HeaderToggleButton.swift
//  AIProject
//
//  Created by kangho lee on 8/13/25.
//

import SwiftUI

struct HeaderToggleButton: View {
    let title: String
    
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
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.aiCoLabelSecondary)
                        .animation(nil, value: sortOrder)
                }
                .padding(.horizontal, 5)
                .frame(width: 20, height: 20)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .overlay {
                    Capsule()
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                }
            }
            .fontWeight(sortOrder != .none ? .bold : .regular)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HeaderToggleButton(title: "Sort", sortOrder: .constant(.none), action: {})
}
