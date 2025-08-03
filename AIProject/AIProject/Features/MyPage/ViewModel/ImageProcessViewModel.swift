//
//  ImageProcessViewModel.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

class ImageProcessViewModel: ObservableObject {
    func processImage(from selectedImage: UIImage) {
        Task {
            let recognizedText = await performOCR(from: selectedImage)
            // TODO: 이미지에 글자가 없는 경우 대응하기
            await convertToSymbol(with: recognizedText)
        }
    }
    
    func performOCR(from selectedImage: UIImage) async -> [String] {
        do {
            return try await TextRecognitionHelper().recognizeText(from: selectedImage)
        } catch {
            print("🚨 OCR 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func convertToSymbol(with text: [String]) async {
        do {
            let answer = try await AlanAPIService().fetchAnswer(content: """
            아래의 문자열 배열에서 가상화폐의 이름을 찾고, 해당 코인의 영문 심볼들을 배열에 담아 반환해. 오타가 있다면 고쳐.
            \(text)
            """)
            print(answer)
        } catch {
            print(error)
        }
    }
}
