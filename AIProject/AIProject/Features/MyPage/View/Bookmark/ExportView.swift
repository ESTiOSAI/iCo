//
//  ActivityView.swift
//  AIProject
//
//  Created by kangho lee on 8/31/25.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// 내보내기 전용 뷰
struct ExportReportView: View {
    let dto: PortfolioBriefingDTO?
    let coins: [BookmarkEntity]
    let imageProvider: (String) -> UIImage?
    
    @Environment(CoinStore.self) var coinStore
    
    @State private var selectedCategory: SortCategory? = .name
    @State private var nameOrder: SortOrder = .none
    @State private var priceOrder: SortOrder = .none
    @State private var volumeOrder: SortOrder = .none
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 브리핑
            if let dto {
                BriefingSectionView(briefing: dto)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.aiCoBackgroundAccent)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.accentGradient, lineWidth: 0.5))
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
            }
            
            CoinListSectionView(
                sortedCoins: coins,
                selectedCategory: $selectedCategory,
                nameOrder: $nameOrder,
                priceOrder: $priceOrder,
                volumeOrder: $volumeOrder,
                imageProvider: imageProvider,
                onDelete: { _ in }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
    }
}
