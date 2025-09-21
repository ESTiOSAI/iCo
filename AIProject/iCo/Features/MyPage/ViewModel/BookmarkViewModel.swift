//
//  BookmarkViewModel.swift
//  AIProject
//
//  Created by 백현진 on 8/1/25.
//

import CoreData
import SwiftUI
import WidgetKit

@MainActor
final class BookmarkViewModel: ObservableObject {
    private let manager: BookmarkManaging = BookmarkManager.shared
    private let llmService: LLMProvider
    private let coinStore: CoinStore

    @Published var briefing: PortfolioBriefingDTO?
    @Published var imageMap: [String: URL] = [:]
    @Published var status: ResponseStatus = .loading

    var task: Task<Void, Never>?

    let userInvestmentType: RiskTolerance = {
        if let raw = UserDefaults.standard.string(forKey: AppStorageKey.investmentType),
           let tolerance = RiskTolerance(rawValue: raw) {
            return tolerance
        }
        return .conservative
    }()

    init(llmService: LLMProvider = LLMAPIService(), coinStore: CoinStore) {
        self.llmService = llmService
        self.coinStore = coinStore
    }

    func loadBriefing(character: RiskTolerance) async {
        status = .loading
        do {
            let bookmarks = try manager.fetchAll()
            guard !bookmarks.isEmpty else {
                briefing = nil
                status = .success
                return
            }

            try Task.checkCancellation()

            let dto = try await llmService.fetchBookmarkBriefing(for: bookmarks, character: character)

            try Task.checkCancellation()

            briefing = dto
            status = .success
        } catch is CancellationError {
            status = .cancel(.taskCancelled)
        } catch let error as NetworkError {
            status = .failure(error)
        } catch {
            print("알 수 없는 에러: \(error)")
        }
    }

    func cancelTask() {
        task?.cancel()
        task = nil
    }

    func deleteAllBookmarks() {
        do {
            try manager.deleteAll()
            briefing = nil
            imageMap = [:]
            saveBookmarkIDsToWidget()
        } catch {
            print(error)
        }
    }

    func deleteBookmark(_ bookmark: BookmarkEntity) {
        do {
            try manager.remove(coinID: bookmark.coinID)
            Task { await loadCoinImages() }
            saveBookmarkIDsToWidget()
        } catch {
            print(error)
        }
    }
    
    func saveBookmarkIDsToWidget() {
        let bookmarks = (try? BookmarkManager.shared.fetchAll()) ?? []

        // coinID → koreanName 매핑
        let nameMap = Dictionary(uniqueKeysWithValues: bookmarks.map { ($0.coinID, $0.coinKoreanName) })

        let defaults = UserDefaults(suiteName: "group.com.est.aico")
        defaults?.set(nameMap, forKey: "widgetBookmarks")

        WidgetCenter.shared.reloadTimelines(ofKind: "CoinWidget")
    }

// MARK: - CoinGecko관련
    func loadCoinImages() async {
        do {
            let bookmarks = try manager.fetchAll()
            guard !bookmarks.isEmpty else {
                imageMap = [:]
                return
            }

            let symbols = Array(
                Set(
                    bookmarks.compactMap {
                        $0.coinID.split(separator: "-").last.map { String($0).uppercased() }
                    }
                )
            )

            var map: [String: URL] = [:]
            for symbol in symbols {
                if let url = CoinImageManager.shared.url(for: symbol) {
                    map[symbol] = url
                }
            }

            imageMap = map
            //print(imageMap)
        } catch {
            print("이미지 로드 실패:", error)
            imageMap = [:]
        }
    }

    func imageURL(for symbol: String) -> URL? {
        let key = symbol
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "-").last.map(String.init) ?? symbol
        return imageMap[key.uppercased()]
    }
    
    func imageProvider(for symbol: String) -> UIImage? {
        guard let url = imageMap[symbol] else { return nil }
        
        return ImageLoader.shared.decodedCache.image(for: url as NSURL)
    }

// MARK: - 북마크 내보내기 관련
    /// scale: 해상도 (2x, 레티나 해상도)
    func makeFullReportImage(scale: CGFloat = 2.0) async -> UIImage? {
        await ImageLoader.shared.prewarm(urls: imageMap.map(\.value))
        let coins: [BookmarkEntity]
            do {
                coins = try manager.fetchAll()
            } catch {
                print("북마크 조회 실패: \(error)")
                return nil
            }

        let targetWidth = currentScreenWidth()

        let exportView = ExportReportView(
            dto: briefing, coins: coins, imageProvider: { [weak self] in self?.imageProvider(for: $0) }
        ).environment(coinStore)
            .frame(width: targetWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        return exportView.snapshotImageExact(
            scale: scale, colorScheme: .light, background: .white, isOpaque: true
        )
    }

    func makeFullReportPNGURL(scale: CGFloat = 2.0) async -> URL? {
        guard let image = await makeFullReportImage(scale: scale),
              let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("briefing_report-\(UUID().uuidString).png")
        do {
            try data.write(to: url); return url
        } catch {
            return nil
        }
    }

    func makeFullReportPDF(scale: CGFloat = 2.0) async -> URL? {
        guard let image = await makeFullReportImage(scale: scale) else { return nil }
        let bounds = CGRect(origin: .zero, size: image.size)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("briefing_report-\(UUID().uuidString).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                image.draw(in: bounds)
            }
            return url
        } catch {
            return nil
        }
    }

    private func currentScreenWidth() -> CGFloat {
        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            return window.bounds.width
        }
        return UIScreen.main.bounds.width
        #else
        return UIScreen.main.bounds.width
        #endif
    }
}
