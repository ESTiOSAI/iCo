//
//  ShareablePNGReport.swift
//  AIProject
//
//  Created by kangho lee on 8/31/25.
//


import SwiftUI
import UniformTypeIdentifiers

/// PNG 공유용
struct ShareablePNGReport: Transferable {
    let generate: () async throws -> URL   // VM의 생성 함수를 주입

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { value in
            // 필요 시 파일을 생성하고 Data로 리턴
            let url = try await value.generate()
            return try Data(contentsOf: url)
        }
    }
}

/// PDF 공유용
struct ShareablePDFReport: Transferable {
    let generate: () async throws -> URL

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { value in
            let url = try await value.generate()
            return try Data(contentsOf: url)
        }
    }
}
