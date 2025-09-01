//
//  Array+Util.swift
//  AIProject
//
//  Created by 백현진 on 8/10/25.
//

import Foundation

extension Array {
    /// 배열을 size의 크기로 잘라서 이차원 배열로 리턴합니다.
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
