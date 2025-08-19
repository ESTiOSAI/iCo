//
//  CoinImageManaging.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol CoinImageManaging {
    func addDict(_ dict: [String: URL]) throws
    func url(for symbol: String) -> URL?
}
