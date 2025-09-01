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
    var mockImage: UIImage!
    
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
    
    // test대상_작업_예상결과
    // OCR 결과 텍스트에 코인 이름이 포함돼있을 때 결과를 정상적으로 반환하는지?
    func testHandleOCR_whenTextContainsCoinNames_returnsCoinList() async throws {
        // Given
        mockImage = ImageProcessTestHelpers.createTestImage(with: "sunrise maple orbit bitcoin velvet")
        sut = TextRecognitionHelper(
            image: mockImage,
            coinNames: mockCoinList
        )
        
        // When
        let raw = try await sut.handleOCR()
        let results = raw.first!.components(separatedBy: " ")
        
        // Then
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains("bitcoin"))
    }
    
    // OCR 결과 텍스트 중 코인 이름이 아닌 문자열에 정상적으로 마스킹이 실행되는지?
    func testHandleOCR_whenTextContainsNonCoinNamesOnly_returnsMaskingCharactorsOnly() async throws {
        // Given
        mockImage = ImageProcessTestHelpers.createTestImage(with: "bittcoin 배트코인")
        sut = TextRecognitionHelper(
            image: mockImage,
            coinNames: mockCoinList
        )
        
        // When
        let ocrResult = try await sut.handleOCR()
        let allCharacters = ocrResult.joined()
        
        // Then
        let maskingCharacters: Set<Character> = ["*", " "]
        XCTAssertTrue(allCharacters.allSatisfy { maskingCharacters.contains($0) })
    }
}
