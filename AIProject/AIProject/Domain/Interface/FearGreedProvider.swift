//
//  FearGreedProvider.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol FearGreedProvider {
    func fetchData() async throws -> [FearGreedIndexDTO]
}
