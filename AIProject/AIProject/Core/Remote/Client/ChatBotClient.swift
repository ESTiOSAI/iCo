//
//  SSEClient.swift
//  AIProject
//
//  Created by 강대훈 on 8/7/25.
//

import Foundation

final class ChatBotClient: NSObject {
    private var task: URLSessionDataTask?
    private var session: URLSession?

    private let url: String = "https://openrouter.ai/api/v1/chat/completions"

    typealias ChatBotStream = AsyncThrowingStream<String, Error>
    private(set) var continuation: ChatBotStream.Continuation?
    var stream: ChatBotStream?

    func connect(content: String) async throws {
        stream = ChatBotStream { continuation in
            self.continuation = continuation
        }

        let request = try configureRequest(content: content)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: request)
        task?.resume()
    }

    func disconnect() {
        continuation?.finish()
        continuation = nil
        stream = nil

        task?.cancel()
        session?.invalidateAndCancel()
    }

    private func configureRequest(content: String) throws -> URLRequest {
        guard let token = Bundle.main.infoDictionary?["CHATBOT_API_KEY"] as? String else {
            throw NetworkError.invalidAPIKey
        }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("text/event-stream", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: Any] = [
            "model": "openai/gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": "\(content)"
                ]
            ],
            "stream": true
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)

        return request
    }
}

extension ChatBotClient: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }

        // SSE는 무조건 하나의 데이터만 들어오는 것이 아니고, 2개의 줄바꿈으로 데이터를 구분하여 들어오기 때문에 파싱이 필요합니다.
        let comps = text.components(separatedBy: "\n\n")

        for comp in comps {
            if let index = comp.firstIndex(of: ":") {
                let afterIndex = comp.index(after: index)
                let subString = comp.suffix(from: afterIndex)

                if let jsonData = subString.data(using: .utf8) {
                    Task { @MainActor in
                        if let jsonObject = try? JSONDecoder().decode(ChatDTO.self, from: jsonData) {
                            let value = jsonObject.choices.first?.delta.content ?? ""
                            continuation?.yield(value)
                        }
                    }
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error { continuation?.finish(throwing: error) }

        disconnect()
    }
}
