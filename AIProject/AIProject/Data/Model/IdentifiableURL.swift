//
//  IdentifiableURL.swift
//  AIProject
//
//  Created by 장지현 on 8/5/25.
//

import Foundation

struct IdentifiableURL: Identifiable {
    let id = UUID().uuidString
    let url: URL
}
