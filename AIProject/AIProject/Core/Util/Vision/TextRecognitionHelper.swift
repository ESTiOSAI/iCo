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
    func recognizeText(from image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "TextRecognitionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "🚨 CGImage가 유효하지 않음"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let results = observations.compactMap { observation -> String? in
                    guard let topCandidate = observation.topCandidates(1).first else { return nil }
                    return self.redactNonKoreanText(in: topCandidate.string)
                }
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
    
    private func redactNonKoreanText(in text: String) -> String {
        let tagger = NLTagger(tagSchemes: [.language])
        tagger.string = text
        
        var redacted = ""
        
        tagger.enumerateTags(
            in: text.startIndex ..< text.endIndex,
            unit: .word,
            scheme: .language,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            let word = String(text[range])
            
            if tag?.rawValue == "ko" {
                redacted += word
            } else {
                redacted += String(repeating: "*", count: word.count)
            }
            redacted += " "
            return true
        }
        
        return redacted.trimmingCharacters(in: .whitespaces)
    }
}
