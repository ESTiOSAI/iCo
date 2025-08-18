//
//  CoinView.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import SwiftUI

struct CoinView: View {
    let symbol: String
    let size: CGFloat
    
    var body: some View {
        CachedAsyncImage(resource: .symbol(symbol)) {
            Text(String(symbol.prefix(1)))
                .font(.caption.bold())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .contentShape(Circle())
        .overlay(
            Circle().strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }
}

