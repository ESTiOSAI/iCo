//
//  NetworkErrorTests.swift
//  AIProjectTests
//
//  Created by 장지현 on 8/14/25.
//

import XCTest
@testable import iCo

final class NetworkErrorTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testErrorDescription_returnsCorrectMessages() {
        let cancelled = NetworkError.taskCancelled
        let exhausted = NetworkError.resourceExhausted(429)
        
        let errors: [NetworkError] = [
            .networkError(URLError(.badURL)),
            .invalidURL,
            .invalidResponse,
            .encodingError,
            .decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "테스트"))),
            .invalidAPIKey,
            .invalidArgument(400),
            .permissionDenied(403),
            .notFound(404),
            .serviceUnavilable(503),
            .deadlineExceeded(504),
            .serverError(505),
            .remoteError(419, "에러"),
            .unknown(999),
            .webSocketError,
        ]
        
        let expectedCancelledMessage = "작업이 취소되었어요\n아래 버튼을 눌러 다시 시도해 주세요"
        let expectedExhaustedMessage = "요청이 많아 지금은 답변할 수 없어요\n잠시 후 다시 시도해 주세요"
        let expectedDefaultMessage = "데이터를 불러오지 못했어요\n잠시 후 다시 시도해 주세요"

        let cancelledMessage = cancelled.errorDescription
        XCTAssertEqual(cancelledMessage, expectedCancelledMessage)
        
        let exhaustedMessage = exhausted.errorDescription
        XCTAssertEqual(exhaustedMessage, expectedExhaustedMessage)
        
        for error in errors {
            XCTAssertEqual(error.errorDescription, expectedDefaultMessage)
        }
    }
    
    func testLog_whenDecodingError_containsDebugDescriptionAndFileFunction() {
        let debugDescription = "Expected String but found Int"
        let decodingError = DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: debugDescription))
        let error = NetworkError.decodingError(decodingError)

        let logOutput = error.log(file: "FakeFile.swift", function: "fakeFunction()")

        XCTAssertTrue(logOutput.contains(debugDescription))
        XCTAssertTrue(logOutput.contains("FakeFile.swift#fakeFunction()"))
    }
}
