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
    @Published var status: ResponseStatus = .loading

    private var task: Task<Void, Never>?

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
            return
        }
        task = Task {
            await MainActor.run {
                status = .loading
            }
            do {
                let dto = try await service.fetchBookmarkBriefing(for: bookmarks, character: character)
                await MainActor.run {
                    briefing = dto
                    status = .success
                }
            } catch is CancellationError {
                await MainActor.run {
                    status = .cancel(.taskCancelled)
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    status = .failure(error)
                }
            } catch {
                await MainActor.run {
                    // 수정 필요
                    status = .failure(NetworkError.unknown(700))
                }
            }
        }
    }

    func cancelTask() {
        task?.cancel()
        task = nil
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

    func deleteBookmark(_ bookmark: BookmarkEntity) {
        do {
            try manager.remove(coinID: bookmark.coinID)

            withAnimation {
                // 리스트에서 제거
                bookmarks.removeAll { $0.objectID == bookmark.objectID }
            }

            Task { await loadCoinImages() }
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

        let symbols = Array(
            Set(
                bookmarks.compactMap {
                    $0.coinID.split(separator: "-").last.map { String($0).uppercased() }
                }
            )
        )

        let map = await geckoService.fetchImageMapBatched(
            symbols: symbols,
            vsCurrency: "krw",
            batchSize: 50,
            maxConcurrentBatches: 3
        )

        await MainActor.run { imageMap = map }
    }

    func imageURL(for symbol: String) -> URL? {
        let key = symbol
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "-").last.map(String.init) ?? symbol
        return imageMap[key.uppercased()]
    }

// MARK: - 북마크 내보내기 관련
    /// scale: 해상도 (2x, 레티나 해상도)
    func makeFullReportImage(scale: CGFloat = 2.0) -> UIImage? {
        guard let dto = briefing, !bookmarks.isEmpty else { return nil }

        let targetWidth = currentScreenWidth()

        let exportView = ExportReportView(
            dto: dto, coins: bookmarks, imageURLProvider: { [weak self] in self?.imageURL(for: $0) }
        )
            .frame(width: targetWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        return exportView.snapshotImageExact(
            scale: scale, colorScheme: .light, background: .white, isOpaque: true
        )
    }

    func makeFullReportPNGURL(scale: CGFloat = 2.0) -> URL? {
        guard let image = makeFullReportImage(scale: scale),
              let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("briefing_report-\(UUID().uuidString).png")
        do {
            try data.write(to: url); return url
        } catch {
            return nil
        }
    }


    func makeFullReportPDF(scale: CGFloat = 2.0) -> URL? {
        guard let image = makeFullReportImage(scale: scale) else { return nil }
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

// 온보딩에서 받는 유저 투자 성격
enum InvestmentCharacter {
    case shortTerm
    case longTerm
}

private extension View {
    /// 캡처 대상 SwiftUI 뷰를 렌더링하여 UIImage로 반환합니다.
    func snapshotImageExact(
        scale: CGFloat = UIScreen.main.scale,
        colorScheme: ColorScheme = .light,
        background: Color = .white,
        isOpaque: Bool = true
    ) -> UIImage? {
        let content = self
            .fixedSize(horizontal: false, vertical: true)
            .background(background)
            .environment(\.colorScheme, colorScheme)

        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        renderer.isOpaque = isOpaque
        return renderer.uiImage
    }
}
