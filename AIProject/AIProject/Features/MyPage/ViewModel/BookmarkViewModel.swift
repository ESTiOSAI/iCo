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

    @Published var bookmarks: [BookmarkEntity] = []
    @Published var briefing: PortfolioBriefingDTO?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    var isBookmarkEmpty: Bool {
        bookmarks.isEmpty
    }

    init(service: AlanAPIService = AlanAPIService()) {
        self.service = service
        fetchBookmarks()
    }

    func loadBriefing(character: InvestmentCharacter) async {
        guard !bookmarks.isEmpty else {
            print("북마크 is empty!")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let dto = try await service.fetchBookmarkBriefing(for: bookmarks, character: character)
            briefing = dto

        } catch let error as NetworkError {
            errorMessage = "네트워크 에러: \(error.localizedDescription)"
        } catch {
            errorMessage = "기타 에러: \(error.localizedDescription)"
        }
    }

    func fetchBookmarks() {
        do {
            bookmarks = try manager.fetchAll()
        } catch {
            bookmarks = []
        }
    }

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
