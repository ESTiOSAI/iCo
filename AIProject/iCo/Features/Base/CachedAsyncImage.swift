//
//  CachedAsyncImage.swift
//  AIProject
//
//  Created by 백현진 on 8/14/25.
//

import SwiftUI

enum CoinResource {
    case url(URL)
    case symbol(String)
}

extension CoinResource: Equatable {
    static func ==(lhs: CoinResource, rhs: CoinResource) -> Bool {
        switch (lhs, rhs) {
        case (.url(let lhsURL), .url(let rhsURL)):
            return lhsURL == rhsURL
        case (.symbol(let lhsSymbol), .symbol(let rhsSymbol)):
            return lhsSymbol == rhsSymbol
        default:
            return false
        }
    }
}

struct CachedAsyncImage<Content: View>: View {
    let resource: CoinResource
    let useCacheOnly: Bool
    
    let placeholder: Content

    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        resource: CoinResource,
        useCacheOnly: Bool = false,
        @ViewBuilder placeholder: () -> Content
    ) {
        self.resource = resource
        self.useCacheOnly = useCacheOnly
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
            }
        }
        .task(id: resource) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            image = try await ImageLoader.shared.image(for: resource, useCacheOnly: useCacheOnly)
        } catch {
            if let error = error as? URLError, error.code == .fileDoesNotExist {
                // TODO: Retry fallback
                print("image 불러오기 실패")
            }
            image = nil
        }
        isLoading = false
    }
}
