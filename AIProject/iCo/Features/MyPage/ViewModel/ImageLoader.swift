//
//  ImageLoader.swift
//  AIProject
//
//  Created by 백현진 on 8/14/25.
//

import UIKit

actor ImageLoader {
    static let shared = ImageLoader()

    let decodedCache: DecodedImageCache
    private var inFlight: [NSURL: Task<UIImage, Error>] = [:]
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache.shared
        return URLSession(configuration: config)
    }()
    
    private init() {
        decodedCache = DecodedImageCache()
    }
    
    func image(for resource: CoinResource, useCacheOnly: Bool = false) async throws -> UIImage {
        switch resource {
        case .url(let url):
            return try await image(for: url, useCacheOnly: useCacheOnly)
        case .symbol(let symbol):
            return try await image(for: symbol, useCacheOnly: useCacheOnly)
        }
    }
    
    private func image(for symbol: String, useCacheOnly: Bool = false) async throws -> UIImage {
        
        guard let key = loadFromDiskCache(from: symbol) else {
            throw URLError(.fileDoesNotExist)
        }
        return try await image(for: key, useCacheOnly: useCacheOnly)
    }

    @discardableResult
    func image(for url: URL, useCacheOnly: Bool = false) async throws -> UIImage {
        let key = url as NSURL
        
        if let img = decodedCache.image(for: key) { return img }

        // 이미 진행 중인 요청이 있으면 합류
        if let running = inFlight[key] {
            return try await running.value
        }

        let task = Task { () throws -> UIImage in
            var request = URLRequest(url: url)
            request.cachePolicy = useCacheOnly ? .returnCacheDataDontLoad : .returnCacheDataElseLoad

            // 디스크 캐시 확인
            if let cached = URLCache.shared.cachedResponse(for: request),
               let img = UIImage(data: cached.data) {
                decodedCache.insert(img, for: key)
//                print("캐시(디스크)에서 이미지 로드됨:", url.lastPathComponent)
                return img
            }

            // TODO: session cancel throw되는지 체크
            // 네트워크 요청
            let (data, response) = try await session.data(for: request)
//            print("네트워크에서 이미지 로드됨:", url.lastPathComponent)
            guard let img = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            // 디스크 캐시에 저장 (HTTP 캐시 가능 응답만 저장됨)
            let cached = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cached, for: request)
            
            decodedCache.insert(img, for: key)

            return img
        }

        inFlight[key] = task
        defer { inFlight[key] = nil }

        return try await task.value
    }

    /// CoreData 조회
    private func loadFromDiskCache(from symbol: String) -> URL? {
        return CoinImageManager.shared.url(for: symbol.uppercased())
    }
}

extension ImageLoader {
    func prewarm(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask { [weak self] in
                   _ = try? await self?.image(for: url)
                }
            }
        }
    }
}

final class DecodedImageCache: @unchecked Sendable {
    static let defaultSize: Int = 128 * 1024 * 1024
    private let cache = NSCache<NSURL, UIImage>()
    
    init(totalCostLimitBytes: Int = defaultSize) {
        cache.totalCostLimit = totalCostLimitBytes
        cache.countLimit = 0
    }
    
    func image(for key: NSURL) -> UIImage? { cache.object(forKey: key) }
    
    func insert(_ image: UIImage, for key: NSURL) {
        cache.setObject(image, forKey: key, cost: imageCost(image))
    }
    
    private func imageCost(_ image: UIImage) -> Int {
        guard let cg = image.cgImage else { return 0 }
        return cg.bytesPerRow * cg.height
    }
}
