//
//  IdentifiableURL.swift
//  AIProject
//
//  Created by 장지현 on 8/5/25.
//

import Foundation

/// `ForEach`, `List` 등에서 사용할 수 있도록 식별자를 제공합니다.
struct IdentifiableURL: Identifiable {
    /// UUID 기반의 고유 식별자
    let id = UUID().uuidString
    /// 실제 URL 객체
    let url: URL
}
