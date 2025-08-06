//
//  ViewState.swift
//  AIProject
//
//  Created by 강대훈 on 8/6/25.
//

import SwiftUI

enum RecommendCoinViewState<View> {
    case loading
    case success([RecommendCoin])
    case failure(Error)
}
