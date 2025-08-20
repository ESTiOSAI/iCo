//
//  CoinListHeaderView.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import SwiftUI

enum Market { }

extension Market {
    enum SortCategory {
        case volume
        case rate
    }
}

struct CoinListHeaderView: View {
    @Binding var sortCategory: Market.SortCategory
    @Binding var rateSortOrder: SortOrder
    @Binding var volumeSortOrder: SortOrder
    
    var body: some View {
        HStack(spacing: 60) {
            HeaderToggleButton(title: "등락폭", sortOrder: $rateSortOrder) {
                sortCategory = .rate
                volumeSortOrder = .none
            }
            
            Spacer()
            
            HeaderToggleButton(title: "거래대금", sortOrder: $volumeSortOrder) {
                sortCategory = .volume
                rateSortOrder = .none
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
                UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16, style: .continuous)
                .stroke(.defaultGradient, lineWidth: 0.5)
        }
    }
}
