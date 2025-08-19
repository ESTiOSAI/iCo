//
//  ResponseStatus.swift
//  AIProject
//
//  Created by 장지현 on 8/12/25.
//

import SwiftUI

enum ResponseStatus {
    case loading
    case success
    case failure(NetworkError)
    case cancel(NetworkError)
}
