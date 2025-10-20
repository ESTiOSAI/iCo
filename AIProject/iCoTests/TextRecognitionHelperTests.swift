//
//  TextRecognitionHelperTests.swift
//  AIProjectTests
//
//  Created by Kitcat Seo on 8/15/25.
//

import XCTest
import Vision
@testable import iCo

// MARK: - TextRecognitionHelper 테스트
final class TextRecognitionHelperTests: XCTestCase {
    var sut: TextRecognitionHelper!
    
    var mockCoinList: Set<String>!
    var mockImage: CGImage!
    
    override func setUp() async throws {
        try await super.setUp()
        mockCoinList = ["bitcoin"]
    }
    
    override func tearDown() async throws {
        sut = nil
        mockCoinList = nil
        mockImage = nil
        try await super.tearDown()
    }
    
    // OCR 결과 텍스트에 코인 이름이 포함돼있을 때 결과를 정상적으로 반환하는지?
    func testHandleOCR_whenTextContainsCoinNames_returnsCoinList() async throws {
        // Given
        guard let mockImage = ImageProcessTestHelpers.createTestImage(with: "sunrise maple orbit bitcoin velvet") else {
            throw XCTSkip("이미지가 정상적으로 생성되지 않음")
        }
        sut = TextRecognitionHelper()
        
        // When
        let raw = try await sut.handleOCR(from: mockImage, with: mockCoinList)
        let results = raw.first!.components(separatedBy: " ")
        
        // Then
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains("bitcoin"))
    }
    
    // OCR 결과 텍스트 중 코인 이름이 아닌 문자열에 정상적으로 마스킹이 실행되는지?
    func testHandleOCR_whenTextContainsNonCoinNamesOnly_returnsMaskingCharactorsOnly() async throws {
        // Given
        guard let mockImage = ImageProcessTestHelpers.createTestImage(with: "bittcoin 배트코인") else {
            throw XCTSkip("이미지가 정상적으로 생성되지 않음")
        }
        sut = TextRecognitionHelper()
        
        // When
        let ocrResult = try await sut.handleOCR(from: mockImage, with: mockCoinList)
        let allCharacters = ocrResult.joined()
        
        // Then
        let maskingCharacters: Set<Character> = ["*", " "]
        XCTAssertTrue(allCharacters.allSatisfy { maskingCharacters.contains($0) })
    }
}
