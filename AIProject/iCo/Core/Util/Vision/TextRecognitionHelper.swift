//
//  TextRecognitionHelper.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI
import Vision
import NaturalLanguage

final class TextRecognitionHelper {
    func handleOCR(from image: CGImage, with coinSet: Set<String>) async throws -> [String] {
        let texts = try await recognizeText(from: image)
        let redacted = texts.map { redactNonCoinName(in: $0, using: coinSet) }
        return redacted
    }
    
    /// OCR을 처리하는 함수
    func recognizeText(from image: CGImage?) async throws -> [String] {
        guard let image else { throw ImageProcessError.unknownVisionError }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, error in
                // DataRace로 인한 참조 해제가 발생하면 안전하게 종료하기
                guard self != nil else {
                    continuation.resume(throwing: ImageProcessError.unknownVisionError)
                    return
                }
                
                // 메모리 부족 등으로 Vision 처리 자체가 실패하면 안전하게 종료하기
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ImageProcessError.unknownVisionError)
                    return
                }
                
                // continuation에서 에러를 반환하면 안전하게 종료하기
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // 결과 Parsing하기
                let results = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: results)
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko-KR"]
            request.usesLanguageCorrection = true
            request.revision = VNRecognizeTextRequestRevision3
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 비식별화를 처리하는 함수
    private func redactNonCoinName(in text: String, using coinNames: Set<String>) -> String {
        var redacted = ""
        
        // lemma 스킴을 사용해 원형 단어를 반환하기
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        tagger.enumerateTags(
            in: text.startIndex ..< text.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitPunctuation, .omitWhitespace]
        ) { tag, range in
            let token = String(text[range]).lowercased()
            
            // 코인 리스트에 없으면 마스킹하기
            if coinNames.contains(token) {
                redacted += token
            } else {
                redacted += String(repeating: "*", count: token.count)
            }
            redacted += " "
            return true
        }
        
        return redacted.trimmingCharacters(in: .whitespaces)
    }
    
    /// 레벤슈타인의 거리를 계산하는 함수
    private func calculateLevenshteinDistance(_ a: String, _ b: String) -> Int {
        let aCount = a.count
        let bCount = b.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: bCount + 1), count: aCount + 1)
        
        for i in 0...aCount {
            matrix[i][0] = i
        }
        
        for j in 0...bCount {
            matrix[0][j] = j
        }
        
        for i in 1...aCount {
            for j in 1...bCount {
                let aChar = a[a.index(a.startIndex, offsetBy: i - 1)]
                let bChar = b[b.index(b.startIndex, offsetBy: j - 1)]
                let cost = (aChar == bChar) ? 0 : 1
                
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[aCount][bCount]
    }
    
    deinit {
        print("helper", #function)
    }
}
