final class MockWebSocketTask: WebSocketType {
    var delegate: URLSessionTaskDelegate?
    private var taskState: URLSessionTask.State = .completed
    
    var state: URLSessionTask.State {
        taskState
    }
    
    private var throwError: Bool
    
    var resumeCallCount: Int = 0
    var cancelCallCount: Int = 0
    var sendCallCount: Int = 0
    var sendPingCallCount: Int = 0
    var receiveCallCount: Int = 0
    
    init(throwError: Bool = false) {
        self.throwError = throwError
    }
    
    func resume() {
        taskState = .suspended
        resumeCallCount += 1
        taskState = .running
        // Delegate 호출이 있어야 함.
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        cancelCallCount += 1
        // Delegate 호출이 있어야 함.
    }
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if throwError {
            throw NSError(
                domain: NSURLErrorDomain,
                code: -1009,
                userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
            )
        }
        
        sendCallCount += 1
    }
    
    func cancel() {
        cancelCallCount += 1
        // Delegate 호출이 있어야 함.
    }
    
    func sendPing(pongReceiveHandler: @escaping ((any Error)?) -> Void) {
        sendPingCallCount += 1
        // 아직 모르겠음.
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        // 어떤 경우에 에러를 던지는지 생각해봐야 함.
        receiveCallCount += 1
        return .string("데이터 잘 받음.")
    }
}