//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI


struct CoinListView: View {
    var body: some View {
        List {
            ForEach(1...10, id: \.self) { _ in
                HStack {
                    HStack {
                        Image(systemName: "swift")
                        
                        Text("비트코인")
                            .bold()
                        
                        Text("BTC")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(1333, format: .number)
                        .foregroundStyle(.red)
                    Text(3, format: <#T##F#>)
                }
            }
        }
    }
}

#Preview {
    CoinListView()
}
