//
//  OnboardingViewModel.swift
//  AIProject
//
//  Created by 백현진 on 8/14/25.
//

import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var imageMap: [String: URL] = [:]

    private let upbitService = UpBitAPIService()
    private let geckoService = CoinGeckoAPIService()

    func loadCoinImages() async {
        do {
            let markets = try await upbitService.fetchMarkets()

            let symbols = Array(Set(
                markets.map { $0.coinSymbol.lowercased() }
            ))

            imageMap = await geckoService.fetchImageBy(symbols: symbols)
            
            try CoinImageManager.shared.addDict(imageMap)
        } catch {
            print("업비트 마켓 불러오기 에러:", error.localizedDescription)
        }
    }
}
