//
//  BookmarkViewModel.swift
//  AIProject
//
//  Created by 백현진 on 8/1/25.
//

import CoreData
import SwiftUI

@MainActor
final class BookmarkViewModel: ObservableObject {
    @Published var coins: [CoinListModel] = []

    private let allCoins = CoinListModel.preview
    private let manager: BookmarkManaging = BookmarkManager.shared

    func loadBookmarks() async {
            do {
                let bookmarkedEntities = try manager.fetchAll()
                let bookmarkedIDs = Set(bookmarkedEntities.map(\.coinID))
                // UI 스레드에서 coins 업데이트
                coins = allCoins.filter { bookmarkedIDs.contains($0.coinID) }
            } catch {
                print("북마크 조회 실패:", error)
            }
        }

    func toggleBookmark(_ coin: CoinListModel) async {
            do {
                let isNowBookmarked = try manager.toggle(coinID: coin.coinID)
                if !isNowBookmarked {
                    coins.removeAll { $0.coinID == coin.coinID }
                }
            } catch {
                print("북마크 토글 실패:", error)
            }
        }

}



