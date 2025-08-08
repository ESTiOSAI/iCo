//
//  UpbitRequest.swift
//  AIProject
//
//  Created by kangho lee on 8/5/25.
//

import Foundation

struct UpbitRequest: Encodable {
    enum FormatType: String, Encodable {
        case `default` = "DEFAULT"
        case simple = "SIMPLE"
        case json = "JSON_LIST"
        case simpleList = "SIMPLE_LIST"
    }
    
    struct FormatField: Encodable {
        let format: FormatType
    }
    
    struct TicketField: Encodable {
        let ticket: String
    }
    
    struct TypeField: Encodable {
        let type: String
        let codes: [String]
        let isOnlySnapshot: Bool = false
        let isOnlyRealTime: Bool = false
        
        enum CodingKeys: String, CodingKey {
            case type
            case codes
            case isOnlySnapshot = "is_only_snapshot"
            case isOnlyRealTime = "is_only_realtime"
        }
    }
    
    let ticket: TicketField
    let type: TypeField
    let format: FormatField
    
    init(ticket: String, type: String, codes: [String], format: FormatType) {
        self.ticket = .init(ticket: ticket)
        self.type = .init(type: type, codes: codes)
        self.format = .init(format: format)
    }
}
