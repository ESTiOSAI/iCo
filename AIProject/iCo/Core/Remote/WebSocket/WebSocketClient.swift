import Foundation
import AsyncAlgorithms

public final class WebSocketClient: NSObject {
    /// 소켓 상태 채널
    private var stateStream: AsyncStream<WebSocket.State>
    /// WebSocket의 상태 변화를 여러 Consumer에게 동시에 전달하는 브로드캐스터
    public var stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State> = .init()
    /// 메세지 채널
    public var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message>
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    private var stateTask: Task<Void, Error>?
    private var receiveTask: Task<Void, Error>?
    
    /// 핑 전송 task
    private var healthCheck: Task<Void, Error>?
    private var pingInterval: Duration = .seconds(30)
    private var pingTimeout: Duration = .seconds(10)
    
    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
        
        stateStream = stateBroadCaster.stream()
        incomingChannel = AsyncChannel<URLSessionWebSocketTask.Message>()
        
        super.init()
        observeState()
    }
    
    /// 웹소켓 세션을 연결하고 작업을 생성합니다.
    public func connect() async {
        await stateBroadCaster.send(.connecting)
        self.task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
        
        // 핑 응답은 연결 후에 오기 때문에 connected 시점을 캐치할 수 있음
        try? await performWithTimeout(sendPing, at: pingTimeout)
    }
    
    /// 명시적으로 현재 WebSocket 연결을 정상적으로 종료합니다.
    ///
    /// 이 메서드는 서버와의 WebSocket 연결을 `normalClosure` 코드로 닫습니다.
    public func disconnect() async {
        task?.cancel(with: .normalClosure, reason: nil)
    }

    /// 텍스트 형태의 메시지를 WebSocket 서버로 전송합니다.
    public func send(text: String) async throws {
        try await task?.send(.string(text))
    }
    
    /// 바이너리(Data) 형태의 메시지를 WebSocket 서버로 전송합니다.
    public func send(data: Data) async throws {
        try await task?.send(.data(data))
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)
        task?.cancel()
        task = nil
        stateBroadCaster.finish()
        incomingChannel.finish()
    }
}

// MARK: - Test용 메소드
// TODO: Deprecated 예정입니다.
extension WebSocketClient {
    public func sendState(with state: WebSocket.State) async {
        await stateBroadCaster.send(state)
    }
    
    public func cancel(with code: URLSessionWebSocketTask.CloseCode) {
        task?.cancel(with: code, reason: nil)
        task = nil
    }
    
    public func cancel() {
        task?.cancel()
        task = nil
    }
}

// MARK: - Private
extension WebSocketClient {
    /// 서버로 Ping 프레임을 전송하여 연결 상태를 확인합니다.
    private func sendPing() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            task?.sendPing { error in
                Task {
                    if let error {
                        debugPrint("Ping Failed: \(error)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    continuation.resume()
                }
            }
        }
    }
    
    /// WebSocket의 상태 변화를 관찰하고 각 상태에 맞는 동작을 수행합니다.
    private func observeState() {
        stateTask = Task {
            for await state in stateStream {
                switch state {
                case .connecting:
                    debugPrint("Connecting")
                    continue
                case .connected:
                    debugPrint("Connected")
                    receive()
                    checkingAlive()
                case .failed, .closed:
                    debugPrint("Closed")
                    release()
                case .reconnecting:
                    debugPrint("Reconnecting")
                    await reconnect()
                }
            }
        }
    }
    
    // FIXME: 개선이 필요한지 한 번 더 생각해보기
    /// 서버로부터 WebSocket 메시지를 지속적으로 수신합니다.
    private func receive() {
        receiveTask?.cancel()
        
        receiveTask = Task {
            do {
                guard let task else { return }
                let message = try await task.receive()
                await incomingChannel.send(message)
                receive()
            } catch {
                print("종료되어 더 이상 웹소켓 데이터를 받지 않습니다.")
            }
        }
    }
    
    /// 주기적으로 Ping을 전송하여 WebSocket 연결 상태를 점검합니다.
    private func checkingAlive() {
        healthCheck?.cancel()
        
        healthCheck = Task {
            do {
                while true {
                    try await Task.sleep(until: .now + pingInterval)
                    try await performWithTimeout(sendPing, at: .seconds(10))
                }
            } catch is CancellationError {
                debugPrint("작업이 취소되었습니다.")
            } catch {
                await stateBroadCaster.send(.reconnecting(nextAttempsIn: .seconds(2)))
            }
        }
    }
    
    /// WebSocket 연결 종료 시 상태를 처리합니다.
    private func handleDisconnected(_ userClose: Bool) async {
        if userClose {
            await stateBroadCaster.send(.closed)
        } else {
            await stateBroadCaster.send(.reconnecting(nextAttempsIn: .seconds(2)))
        }
    }
    
    /// WebSocket 재연결을 시도합니다.
    private func reconnect() async {
        guard task?.state != .running else {
            return
        }
        
        try? await Task.sleep(for: .seconds(2))
        await connect()
    }
    
    /// WebSocket 클라이언트의 모든 비동기 작업과 연결을 종료하고 리소스를 정리합니다.
    private func release() {
        receiveTask?.cancel()
        receiveTask = nil
        healthCheck?.cancel()
        healthCheck = nil
        
        if task?.state == .running {
            task?.cancel(with: .goingAway, reason: nil)
        }
        
        task = nil
    }
}

// MARK: 웹 소켓 Delegate로 소켓 응답 및 종료 event를 받아 처리합니다.
extension WebSocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { await stateBroadCaster.send(.connected) }
    }
    
    // 웹소켓으로부터 Close Code를 받았을 때. (정상 종료로 닫혔을 때)
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { await handleDisconnected(closeCode == .normalClosure) }
    }
    
    // 세션 레벨에서 작업이 완전히 종료됐을 때.
    // 1. 네트워크 닫힘, 2. 에러로 종료, 3. 정상적으로 완료
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let _ = error {
            Task { await stateBroadCaster.send(.reconnecting(nextAttempsIn: .seconds(2))) }
        }
    }
}

