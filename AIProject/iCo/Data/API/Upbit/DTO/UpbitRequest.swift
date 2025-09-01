//
//  UpbitRequest.swift
//  AIProject
//
//  Created by kangho lee on 8/5/25.
//

import Foundation

public enum SubscribeRequest: Encodable {
    enum Component: Encodable {
        case ticket(String)
        case format(FormatType)
        case body(BodyType)
        
        enum FormatType: String, Encodable {
            case `default` = "DEFAULT"
            case simple = "SIMPLE_LIST"
        }
        
        struct BodyType: Encodable {
            let method: String
            let codes: [String]
            
            enum CodingKeys: String, CodingKey {
                case method = "type"
                case codes
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .ticket(let ticket):
                try container.encode(["ticket": ticket])
            case .format(let formatType):
                try container.encode(["format": formatType.rawValue])
            case .body(let bodyType):
                try container.encode(bodyType)
            }
        }
    }
    
    case ticker(ticket: String, codes: [String])
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        for component in components() {
            try container.encode(component)
        }
    }
    
    func components() -> [Component] {
        switch self {
        case .ticker(ticket: let ticket, codes: let codes):
            return [.ticket(ticket), .body(.init(method: "ticker", codes: codes)), .format(.default)]
        }
    }
}
