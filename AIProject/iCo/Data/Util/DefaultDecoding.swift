//
//  DefaultDecoding.swift
//  AIProject
//
//  Created by kangho lee on 8/28/25.
//

import Foundation

@propertyWrapper
struct Default<T: DefaultValue & Decodable>: Decodable {
    var wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        self.wrappedValue = (try? container?.decode(T.self)) ?? T.defaultValue
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T>
    where T: DefaultValue & Decodable {
        try decodeIfPresent(Default<T>.self, forKey: key)
            ?? Default(wrappedValue: T.defaultValue)
    }
}

protocol DefaultValue {
    static var defaultValue: Self { get }
}
