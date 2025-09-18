//
//  AppConnectivityManager.swift
//  iCo
//
//  Created by Kanghos on 9/18/25.
//

import Foundation

@Observable
final class AppConnectivityManager {
    let banner = TopBannerController()
    private let connectivity: ConnectivityMonitor

    init(connectivity: ConnectivityMonitor) {
        self.connectivity = connectivity
        Task { [weak self] in
            guard let self else { return }
            var last = connectivity.isOnline

            while true {
                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s 마다 감지
                let now = self.connectivity.isOnline
                guard now != last else { continue }
                last = now
                await MainActor.run {
                    if now {
                        self.banner.showOnline("온라인 상태입니다")
                    } else {
                        self.banner.showOffline("오프라인 상태입니다")
                    }
                }
            }
        }
    }
}
