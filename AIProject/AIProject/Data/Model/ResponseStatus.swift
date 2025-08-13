//
//  ResponseStatus.swift
//  AIProject
//
//  Created by 장지현 on 8/12/25.
//

import SwiftUI

enum ResponseStatus: Equatable {
    case loading
    case success
    case failure(NetworkError)
    case cancel(NetworkError)
    
    static func == (lhs: ResponseStatus, rhs: ResponseStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.success, .success):
            return true
        case (.failure, .failure),
             (.cancel, .cancel):
            return true
        default:
            return false
        }
    }
}
