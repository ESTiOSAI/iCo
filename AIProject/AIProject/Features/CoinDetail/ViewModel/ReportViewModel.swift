//
//  ReportViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/1/25.
//

import Foundation

final class ReportViewModel: ObservableObject {
    let coin: Coin
    let koreanName: String
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
    }
    
    private func fetch<T: Decodable>(
        content: String,
        decodeType: T.Type,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping () -> Void
    ) {
        Task {
            do {
                let answer = try await AlanAPIService().fetchAnswer(content: content)
                guard let jsonData = extractJSON(from: answer.content).data(using: .utf8) else {
                    await MainActor.run { onFailure() }
                    return
                }
                let data = try JSONDecoder().decode(T.self, from: jsonData)
                await MainActor.run { onSuccess(data) }
            } catch {
                print("오류 발생: \(error.localizedDescription)")
                await MainActor.run { onFailure() }
            }
        }
    }
}
