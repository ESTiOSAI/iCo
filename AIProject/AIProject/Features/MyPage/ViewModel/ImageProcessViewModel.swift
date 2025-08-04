//
//  ImageProcessViewModel.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

class ImageProcessViewModel: ObservableObject {
    @Published var isLoading = false
    
    func processImage(from selectedImage: UIImage) {
        Task {
            await MainActor.run { self.isLoading = true }
            
            let recognizedText = await performOCR(from: selectedImage)
            // TODO: 이미지에 글자가 없는 경우 대응하기
            if let convertedSymbols = await convertToSymbol(with: recognizedText) {
                
                var verifiedCoinIDs = [String]()
                for symbol in convertedSymbols {
                    do {
                        let krwSymbolName = "KRW-\(symbol)"
                        let verified = try await UpBitAPIService().verifyCoinID(id: krwSymbolName)
                        
                        if verified {
                            verifiedCoinIDs.append(krwSymbolName)
                        } else {
                            continue
                        }
                        
                    } catch {
                        print(error)
                    }
                }
                
                print(verifiedCoinIDs)
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    func performOCR(from selectedImage: UIImage) async -> [String] {
        do {
            return try await TextRecognitionHelper.recognizeText(from: selectedImage)
        } catch {
            print("🚨 OCR 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // TODO: 인식한 텍스트 주변에 박스 그리기
    
    func convertToSymbol(with text: [String]) async -> [String]? {
        do {
            let answer = try await AlanAPIService().fetchAnswer(content: """
            아래의 문자열 배열에서 가상화폐의 이름을 찾아서 해당 코인의 영문 심볼들을 반환해. 오타가 있다면 고쳐주고 "," 로 구분해서 JSON으로 반환해.
            \(text)
            """)
            
            let convertedSymbols = answer.content.extractedJSON
                .replacingOccurrences(of: "\"", with:"")
                .components(separatedBy: ",")
            
            return convertedSymbols
        } catch {
            print(error)
            return nil
        }
    }
}
