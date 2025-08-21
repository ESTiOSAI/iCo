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

struct CachedAsyncImage<Content: View>: View {
    let resource: CoinResource
    let useCacheOnly: Bool
    
    let placeholder: Content

    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(resource: CoinResource, useCacheOnly: Bool = false, @ViewBuilder placeholder: () -> Content) {
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
                    .background(.background)
            } else {
                placeholder
            }
        }
        .task {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            image = try await ImageLoader.shared.image(for: resource, useCacheOnly: useCacheOnly)
        } catch {
            print("이미지 로드 실패:", error.localizedDescription)
        }
        isLoading = false
    }
}
