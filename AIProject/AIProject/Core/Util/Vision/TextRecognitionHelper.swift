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
    private var image: UIImage
    private var coinNames: Set<String>
    
    init(image: UIImage, coinNames: Set<String>) {
        self.image = image
        self.coinNames = coinNames
    }
    
    func handleOCR() async throws -> [String] {
        let texts = try await recognizeText()
        let redacted = texts.map { redactNonCoinName(in: $0) }
        return redacted
    }
    
    /// OCR을 처리하는 함수
    func recognizeText() async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "TextRecognitionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "🚨 CGImage가 유효하지 않음"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard self != nil else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let results = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: results)
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko-KR"]
            request.usesLanguageCorrection = true
            request.revision = VNRecognizeTextRequestRevision3
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 비식별화를 처리하는 함수
    private func redactNonCoinName(in text: String) -> String {
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
