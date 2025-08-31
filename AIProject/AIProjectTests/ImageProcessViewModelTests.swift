//
//  ImageProcessViewModelTests.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/17/25.
//

import XCTest
@testable import AIProject

// MARK: - ImageProcessViewModel 테스트
final class ImageProcessViewModelTests: XCTestCase {
    var sut: ImageProcessViewModel!
    
    var mockCoinList: [CoinDTO]!
    var mockImage: UIImage!
    
    override func setUp() async throws {
        try await super.setUp()
        mockCoinList = [ImageProcessTestHelpers.createMockCoinDTO()]
    }
    
    override func tearDown() async throws {
        if sut != nil {
            await sut.cancelTask()
        }
        mockCoinList = nil
        sut = nil
        mockImage = nil
        try await super.tearDown()
    }
    
    // 이미지에서 글자를 찾지 못했을 때 알맞은 에러를 반환하는지?
    func testImageProcessViewModel_whenNoTextIsReturned_terminateWithError() async throws {
        // Given
        mockImage = ImageProcessTestHelpers.createTestImage(with: "")
        
        // When
        sut = ImageProcessViewModel()
        sut.coinList = mockCoinList
        sut.processImage(from: mockImage)
        
        if let task = sut.processImageTask {
            _ = try? await task.value
        }
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showAnalysisResultAlert)

        XCTAssertTrue(sut.showErrorMessage)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.verifiedCoinList.isEmpty)
        
        XCTAssertEqual(sut.errorMessage, ImageProcessError.noRecognizedText.description)
    }
    
    // Alan에게서 코인 이름을 받아오지 못했을 때 알맞은 에러를 반환하는지?
    func testImageProcessViewModel_whenNoConvertedSymbol_terminateWithError() async throws {
        // Alan API키를 검증하고, 키가 없을 시에는 테스트 건너뛰기
        guard let apiKey = Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_ID_EXTRACTION"] as? String,
              !apiKey.isEmpty else {
            throw XCTSkip("테스트에 필요한 Alan API 키를 읽어오지 못함")
        }
        
        // Given
        mockImage = ImageProcessTestHelpers.createTestImage(with: "bittcoin batcoin")
        
        // When
        sut = ImageProcessViewModel()
        sut.coinList = mockCoinList
        sut.processImage(from: mockImage)
        
        if let task = sut.processImageTask {
            _ = try? await task.value
        }
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showAnalysisResultAlert)

        XCTAssertTrue(sut.showErrorMessage)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.verifiedCoinList.isEmpty)
        
        XCTAssertEqual(sut.errorMessage, ImageProcessError.noExtractedCoinID.description)
    }
}
