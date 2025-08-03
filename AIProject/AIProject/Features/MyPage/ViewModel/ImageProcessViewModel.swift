//
//  ImageProcessViewModel.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

class ImageProcessViewModel: ObservableObject {
    func performOCR(from selectedImage: UIImage) {
        Task {
            do {
                let result = try await TextRecognitionHelper().recognizeText(from: selectedImage)
            } catch {
                print("🚨 OCR 실패: \(error.localizedDescription)")
            }
        }
    }
    
    //func /
}
