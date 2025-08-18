//
//  CoinListHeaderView.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import SwiftUI

struct CoinListHeaderView: View {
    @Binding var sortCategory: SortCategory
    @Binding var nameSortOrder: SortOrder
    @Binding var volumeSortOrder: SortOrder
    
    var body: some View {
        HStack(spacing: 60) {
            SortToggleButton2(title: "한글명", sortCategory: .name, sortOrder: $nameSortOrder) {
                sortCategory = .name
                volumeSortOrder = .none
            }
            
            Spacer()
            
            SortToggleButton2(title: "거래대금", sortCategory: .volume, sortOrder: $volumeSortOrder) {
                sortCategory = .volume
                nameSortOrder = .none
            }
        }
        .frame(maxWidth: .infinity)
    }
}
