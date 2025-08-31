//
//  CoinView.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import SwiftUI

struct CoinView: View {
    
    /// symbol 예) BTC, ETH
    let symbol: String
    let size: CGFloat
    
    /// ImageRenderer는 리렌더링 하기 때문에 비동기 작업을 기다리지 않음
    var prefetched: UIImage? = nil
    
    var body: some View {
        Group {
            if let prefetched {
                Image(uiImage: prefetched)
                    .resizable()
                    .scaledToFit()
            } else {
                CachedAsyncImage(resource: .symbol(symbol)) {
                    Text(String(symbol.prefix(1)))
                        .font(.system(size: size / 2))
                        .foregroundStyle(.aiCoAccent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.aiCoBackgroundAccent)
                        .overlay(
                            Circle().strokeBorder(.defaultGradient, lineWidth: 0.5)
                        )
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .contentShape(Circle())
        .id(symbol)
    }
}

#Preview {
    CoinView(symbol: "KWR-BTC", size: 40)
}
