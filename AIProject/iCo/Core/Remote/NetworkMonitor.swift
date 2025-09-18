//
//  NetworkMonitor.swift
//  iCo
//
//  Created by Kanghos on 9/17/25.
//

import Network
import Observation

@Observable
final class ConnectivityMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "net.connectivity")

    private(set) var isOnline: Bool = true
    /// Cellular, Hotspot
    private(set) var isExpensive: Bool = false
    /// 네트워크 절약 모드
    private(set) var isConstrained: Bool = false
    /// wifi, cellular
    private(set) var interface: NWInterface.InterfaceType? = nil

    private var continuation: CheckedContinuation<Bool, Never>?

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.isOnline = (path.status == .satisfied)
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained
            self.interface = path.availableInterfaces
                .first(where: { path.usesInterfaceType($0.type) })?.type
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
