//
//  BookmarkExportTests.swift
//  AIProjectTests
//
//  Created by 백현진 on 8/16/25.
//

import XCTest
@testable import AIProject

@MainActor
final class BookmarkExportTests: XCTestCase {

    var sut: BookmarkViewModel!

    override func setUp() {
        super.setUp()

        sut = BookmarkViewModel(service: AlanAPIService())

        sut.briefing = PortfolioBriefingDTO(briefing: "투자 브리핑", strategy: "전략 제안")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_makeReportPNGURL_createValidExport() {
        let fake = FakeBookmarkEntity()
        fake.coinID = "KRW-BTC"
        fake.coinKoreanName = "비트코인"
        fake.timestamp = Date()

        guard let url = sut.makeFullReportPNGURL(scale: 2.0) else {
            XCTFail("PNG 생성 실패")
            return
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "실제 파일 존재 안함")

    	let data = try? Data(contentsOf: url)
        XCTAssertNotNil(data, "PNG 파일 nil")
        XCTAssertFalse(data!.isEmpty, "PNG is Empty")
    }

    func test_makeFullReportPDF_createsValidFile() {
        let fake = FakeBookmarkEntity()
        fake.coinID = "KRW-BTC"
        fake.coinKoreanName = "비트코인"
        fake.timestamp = Date()

        guard let url = sut.makeFullReportPDF(scale: 1.0) else {
            XCTFail("PDF URL 생성 실패")
            return
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "파일이 실제로 생성되어야 함")

        let data = try? Data(contentsOf: url)
        XCTAssertNotNil(data, "PDF 파일 nil")
        XCTAssertFalse(data!.isEmpty, "PDF is Empty")

        // PDF 파일은 "%PDF"로 시작
        let prefix = String(data!.prefix(4).map { Character(UnicodeScalar($0)) })
        XCTAssertEqual(prefix, "%PDF", "PDF 파일은 %PDF 헤더로 시작해야 함")
    }
}

final class FakeBookmarkEntity: BookmarkEntity {
    override var coinID: String {
        get { backingID }
        set { backingID = newValue }
    }
    override var coinKoreanName: String {
        get { backingName }
        set { backingName = newValue }
    }
    override var timestamp: Date {
        get { backingDate }
        set { backingDate = newValue }
    }

    private var backingID: String = ""
    private var backingName: String = ""
    private var backingDate: Date = Date()
}
