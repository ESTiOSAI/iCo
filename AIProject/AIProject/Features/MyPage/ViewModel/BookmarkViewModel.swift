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
    private let manager: BookmarkManaging = BookmarkManager.shared
    private let service: AlanAPIService
    private let geckoService: CoinGeckoAPIService

    @Published var bookmarks: [BookmarkEntity] = []
    @Published var briefing: PortfolioBriefingDTO?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var imageMap: [String: URL] = [:]

    var isBookmarkEmpty: Bool {
        bookmarks.isEmpty
    }

    init(service: AlanAPIService = AlanAPIService(), geckoService: CoinGeckoAPIService = CoinGeckoAPIService()) {
        self.service = service
        self.geckoService = geckoService
        fetchBookmarks()
    }

    func loadBriefing(character: InvestmentCharacter) async {
        guard !bookmarks.isEmpty else {
            print("북마크 is empty!")
            return
        }

        isLoading = true
        defer { isLoading = false }   // @MainActor 컨텍스트이므로 안전

        do {
            let dto = try await service.fetchBookmarkBriefing(for: bookmarks, character: character)
            briefing = dto
            errorMessage = nil
        } catch let error as NetworkError {
            errorMessage = "네트워크 에러: \(error.localizedDescription)"
            print("❌ loadBriefing NetworkError:", error)   // 어떤 NetworkError인지 확인
        } catch {
            errorMessage = "기타 에러: \(error.localizedDescription)"
            print("❌ loadBriefing error:", error)
        }
    }

    func fetchBookmarks() {
        do {
            bookmarks = try manager.fetchAll()
        } catch {
            bookmarks = []
        }
    }

    func deleteAllBookmarks() {
        do {
            try manager.deleteAll()
                bookmarks = []
                imageMap = [:]       
                briefing = nil
                errorMessage = nil

        } catch {
            print(error)
        }
    }

// MARK: - CoinGecko관련
    func loadCoinImages() async {
        guard !bookmarks.isEmpty else {
            await MainActor.run { imageMap = [:] }
            return
        }
        do {
            let map = try await geckoService.fetchImageMapForBookmarks(bookmarks)
            await MainActor.run { imageMap = map }
        } catch {
            await MainActor.run { imageMap = [:] }
            print("코인 이미지 로드 에러\(error.localizedDescription)")
        }
    }

    func imageURL(for symbol: String) -> URL? {
        let key = symbol
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        return imageMap[key]
    }

// MARK: - 북마크 내보내기 관련
    func exportBriefingImage() {
        let view = BriefingSectionView(
            briefing: briefing,
            isLoading: false,
            bookmarksEmpty: false,
            errorMessage: nil
        )
        let image = view.snapshot()

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// 온보딩에서 받는 유저 투자 성격
enum InvestmentCharacter {
    case shortTerm
    case longTerm
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
