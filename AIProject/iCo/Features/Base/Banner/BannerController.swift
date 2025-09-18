//
//  BannerController.swift
//  iCo
//
//  Created by Kanghos on 9/18/25.
//

import Foundation
import Observation

@Observable
final class TopBannerController {
    enum Kind { case online, offline }

    var isVisible: Bool = false
    var message: String = ""
    var kind: Kind = .offline

    private var hideTask: Task<Void, Never>?

    func showOffline(_ text: String = "오프라인입니다. 네트워크에 연결해 주세요.") {
        hideTask?.cancel()
        kind = .offline
        message = text
        isVisible = true                 // 항상 표시 (자동 숨김 없음)
    }

    func showOnline(_ text: String = "온라인 복귀!") {
        hideTask?.cancel()
        kind = .online
        message = text
        isVisible = true
        // 3초 후 자동 숨김
        hideTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3s 후 숨김
            await MainActor.run { self.isVisible = false }
        }
    }
}
