//
//  SSEClient.swift
//  AIProject
//
//  Created by 강대훈 on 8/7/25.
//

import Foundation

final class SSEClient: NSObject {
    private var task: URLSessionDataTask?
    private var session: URLSession?

    typealias SSEStream = AsyncThrowingStream<String, Error>
    private(set) var continuation: SSEStream.Continuation?
    var stream: SSEStream?

    func connect(to url: URL, token: String) {
        let request = configureRequest(to: url, token: token)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: request)
        task?.resume()
    }

    func disconnect() {
        task?.cancel()
        session?.invalidateAndCancel()
    }

    private func configureRequest(to url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("text/event-stream", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: Any] = [
            "model": "openai/gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": "안녕? 오늘 한국 날씨는 어때?"
                ]
            ],
            "stream": true
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)

        return request
    }
}

extension SSEClient: URLSessionDataDelegate {
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
                            print(value)
                        }
                    }
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            print("에러 발생: \(error.localizedDescription)")
        } else {
            print("성공!")
        }
    }
}
