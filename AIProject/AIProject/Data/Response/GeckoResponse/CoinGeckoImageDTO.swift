//
//  CoinGeckoImageDTO.swift
//  AIProject
//
//  Created by 백현진 on 8/8/25.
//

import Foundation

struct CoinGeckoImageDTO: Codable, Identifiable {
    let id: String
    let symbol: String
    let image: String?

    var imageURL: URL? { image.flatMap(URL.init(string:)) }
}
