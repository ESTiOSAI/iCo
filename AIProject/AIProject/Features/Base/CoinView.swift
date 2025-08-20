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
                .font(.system(size: size / 2))
                .foregroundStyle(.aiCoAccent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.aiCoBackgroundAccent)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .contentShape(Circle())
        .overlay(
            Circle().strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
    }
}

#Preview {
    CoinView(symbol: "KWR-BTC", size: 40)
}
