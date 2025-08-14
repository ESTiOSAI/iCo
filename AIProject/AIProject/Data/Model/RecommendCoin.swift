//
//  RecommendCoin.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoin: Identifiable {
    enum TickerChangeType: String {
        case rise = "RISE"
        case even = "EVEN"
        case fall = "FALL"

        init(rawValue: String) {
            switch rawValue {
            case "RISE": self = .rise
            case "EVEN": self = .even
                case "FALL": self = .fall
            default:
                self = .rise
            }
        }

        var changeColor: Color {
            switch self {
            case .rise: return .aiCoPositive
            case .even: return .aiCoLabel
            case .fall: return .aiCoNegative
            }
        }

        var code: String {
            switch self {
            case .rise: return "▲"
            case .even: return ""
            case .fall: return "▼"
            }
        }
    }

    var id: String { coinID }

    var imageURL: URL?
    let comment: String
    let coinID: String
    let name: String
    let tradePrice: Double
    let changeRate: Double
    let changeType: TickerChangeType
}
