import Foundation
import AsyncAlgorithms

public protocol WebSocketProvider {
    var stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State> { get }
    var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message> { get }
    
    /// 웹소켓 세션을 연결하고 작업을 생성합니다.
    func connect() async
    
    /// 명시적으로 현재 WebSocket 연결을 정상적으로 종료합니다.
    ///
    /// 이 메서드는 서버와의 WebSocket 연결을 `normalClosure` 코드로 닫습니다.
    func disconnect() async
    
    /// 텍스트 형태의 메시지를 WebSocket 서버로 전송합니다.
    func send(text: String) async throws
    
    /// 바이너리(Data) 형태의 메시지를 WebSocket 서버로 전송합니다.
    func send(data: Data) async throws
}

public protocol URLSessionType {
    func makeWebSocketTask(with url: URL) -> WebSocketType
}

public protocol WebSocketType {
    var delegate: (any URLSessionTaskDelegate)? { get set }
    var state: URLSessionTask.State { get }
    
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func cancel()
    func sendPing(pongReceiveHandler: @escaping @Sendable((any Error)?) -> Void)
    func receive() async throws -> URLSessionWebSocketTask.Message
}

extension URLSession: URLSessionType {
    public func makeWebSocketTask(with url: URL) -> any WebSocketType {
        return webSocketTask(with: url)
    }
}

extension URLSessionWebSocketTask: WebSocketType {}

public class WebSocketClient: NSObject, WebSocketProvider {
    /// 소켓 상태 채널
    private var stateStream: AsyncStream<WebSocket.State>
    /// WebSocket의 상태 변화를 여러 Consumer에게 동시에 전달하는 브로드캐스터
    public var stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State>
    /// 메세지 채널
    public var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message>
    
    private(set) var url: URL
    private(set) var session: URLSessionType
    private(set) var task: WebSocketType?
    
    private(set) var stateTask: Task<Void, Error>?
    private(set) var receiveTask: Task<Void, Error>?
    
    /// 핑 전송 task
    private(set) var healthCheck: Task<Void, Error>?
    private var pingInterval: Duration = .seconds(30)
    private var pingTimeout: Duration = .seconds(10)
    private var attempts: Int = 0
    
    public init(
        url: URL,
        session: URLSessionType = URLSession.shared,
        stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State> = .init()
    ) {
        self.url = url
        self.session = session
        self.stateBroadCaster = stateBroadCaster
        
        stateStream = stateBroadCaster.stream()
        incomingChannel = AsyncChannel<URLSessionWebSocketTask.Message>()
        
        super.init()
        observeState()
    }
    
    /// 웹소켓 세션을 연결하고 작업을 생성합니다.
    public func connect() async {
        await stateBroadCaster.send(.connecting)
        self.task = session.makeWebSocketTask(with: url)
        task?.delegate = self
        task?.resume()
    }
    
    /// 명시적으로 현재 WebSocket 연결을 정상적으로 종료합니다.
    ///
    /// 이 메서드는 서버와의 WebSocket 연결을 `normalClosure` 코드로 닫습니다.
    public func disconnect() async {
        task?.cancel(with: .normalClosure, reason: nil)
    }

    /// 텍스트 형태의 메시지를 WebSocket 서버로 전송합니다.
    public func send(text: String) async throws {
        guard let task else { throw NetworkError.networkError(URLError(.notConnectedToInternet)) }
        try await task.send(.string(text))
    }
    
    /// 바이너리(Data) 형태의 메시지를 WebSocket 서버로 전송합니다.
    public func send(data: Data) async throws {
        guard let task else { throw NetworkError.networkError(URLError(.notConnectedToInternet)) }
        try await task.send(.data(data))
    }
}

// MARK: - Private
extension WebSocketClient {
    /// WebSocket의 상태 변화를 관찰하고 각 상태에 맞는 동작을 수행합니다.
    private func observeState() {
        stateTask = Task {
            for await state in stateStream.removeDuplicates() {
                switch state {
                case .connecting:
                    debugPrint("Connecting")
                    continue
                case .connected:
                    debugPrint("Connected")
                    clearAttempts()
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
    
    /// 서버로부터 WebSocket 메시지를 지속적으로 수신합니다.
    private func receive() {
        receiveTask = Task {
            while true {
                guard let task else { throw NetworkError.taskCancelled }
                let message = try await task.receive()
                await incomingChannel.send(message)
            }
        }
    }
    
    /// 주기적으로 Ping을 전송하여 WebSocket 연결 상태를 점검합니다.
    private func checkingAlive() {
        healthCheck = Task {
            do {
                while true {
                    try await performWithTimeout(sendPing, at: pingTimeout)
                    try await Task.sleep(until: .now + pingInterval)
                }
            } catch is CancellationError {
                debugPrint("작업이 취소되었습니다.")
            } catch {
                if handlePingError(error) {
                    if task?.state == .running {
                        task?.cancel()
                    }
                }
            }
        }
    }
    
    /// sendPing(:) 으로부터 받은 에러를 핸들링하는 메소드입니다.
    /// - Parameter error: 에러를 전달받습니다.
    /// - Returns: 재연결해야 한다면 true를 반환합니다.
    private func handlePingError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code { // URLError (네트워크 단절)
                case .notConnectedToInternet, .networkConnectionLost:
                    return true
                default:
                    return false
            }
        } else if let posixError = error as? POSIXError {
            switch posixError.code { // POSIXError (소켓이 죽음)
                case .EPIPE, .ECONNRESET:
                    return true
                default:
                    return false
            }
        } else { // 소켓이 정상상태가 아님.
            return true
        }
    }
    
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
    
    /// WebSocket 연결 종료 시 상태를 처리합니다.
    private func handleDisconnected(_ userClose: Bool) async {
        if userClose {
            await stateBroadCaster.send(.closed)
        } else {
            await stateBroadCaster.send(.reconnecting)
        }
    }
    
    private func clearAttempts() {
        attempts = 0
    }
    
    /// WebSocket 재연결시에 백오프를 적용합니다.
    /// - Returns: 백오프하는 시간을 Int 타입으로 반환합니다.
    private func backoff() -> Int {
        attempts += 1
        let base = min(pow(2.0, Double(attempts)) * 100.0, 10000)
        let jitter = Double.random(in: 0.5...1.0)
        
        return Int(base * jitter)
    }
    
    /// WebSocket 재연결을 시도합니다.
    private func reconnect() async {
        if task?.state == .running || attempts > 10 { return }
        try? await Task.sleep(for: .milliseconds(backoff()))
        await connect()
    }
    
    /// WebSocket 클라이언트의 모든 비동기 작업과 연결을 종료하고 리소스를 정리합니다.
    private func release() {
        receiveTask?.cancel()
        receiveTask = nil
        healthCheck?.cancel()
        healthCheck = nil
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
            Task { await stateBroadCaster.send(.reconnecting) }
        }
    }
}

