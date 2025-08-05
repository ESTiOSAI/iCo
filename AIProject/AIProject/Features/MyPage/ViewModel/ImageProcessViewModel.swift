//
//  ImageProcessViewModel.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

/// 북마크 대량 등록을 관련 작업들을 처리하는 뷰모델
class ImageProcessViewModel: ObservableObject {
    @Published var isLoading = false
    
    @Published var showAnalysisResultAlert = false
    @Published var verifiedCoinIDs = [String]()
    
    /// 북마크 대량 등록을 위해 이미지에 대한 비동기 처리를 컨트롤하는 함수
    func processImage(from selectedImage: UIImage) {
        Task {
            await MainActor.run { self.isLoading = true }
            
            let recognizedText = await performOCR(from: selectedImage)
            // TODO: 이미지에 글자가 없는 경우 대응하기
            if let convertedSymbols = await convertToSymbol(with: recognizedText) {
                // 검증된 coinID만 배열에 담기
                for symbol in convertedSymbols {
                    do {
                        // 한국 마켓만 사용하므로 한국 마켓 이름 추가하기
                        let krwSymbolName = "KRW-\(symbol)"
                        let verified = try await UpBitAPIService().verifyCoinID(id: krwSymbolName)
                        
                        if verified {
                            await MainActor.run {
                                self.verifiedCoinIDs.append(krwSymbolName)
                            }
                        } else {
                            continue
                        }
                    } catch {
                        print(error)
                    }
                }
                
                print(verifiedCoinIDs)
                await MainActor.run {
                    self.isLoading = false
                    self.showAnalysisResultAlert = true
                }
            }
        }
    }
    
    /// 전달된 이미지에 OCR을 처리하고 비식별화된 문자열 배열을 받아오는 함수
    func performOCR(from selectedImage: UIImage) async -> [String] {
        do {
            return try await TextRecognitionHelper.recognizeText(from: selectedImage)
        } catch {
            print("🚨 OCR 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // TODO: 인식한 텍스트 주변에 박스 그리기
    
    /// Alan을 이용해 전달받은 문자열 배열에서 coinID를 추출하는 함수
    func convertToSymbol(with text: [String]) async -> [String]? {
        if !text.isEmpty {
            do {
                let answer = try await AlanAPIService().fetchAnswer(content: """
            아래의 문자열 배열에서 가상화폐의 이름을 찾아서 빈 배열에 해당 코인의 영문 심볼들을 반환해. 오타가 있다면 고쳐주고 "," 로 구분해서 JSON으로 반환해.
            \(text)
            """, action: .coinIDExtraction)
                
                let convertedSymbols = answer.content.extractedJSON
                    .replacingOccurrences(of: "\"", with:"") // "\" 문자 제거하기
                    .components(separatedBy: ",") // "," 기준으로 나누기
                return convertedSymbols
            } catch {
                print(error)
                return nil
            }
        } else {
            print("전달 받은 텍스트가 없습니다!!")
            await MainActor.run { self.isLoading = false }
            return nil
        }
    }
    
    func addToBookmark() {
        do {
            for coinId in verifiedCoinIDs {
                try BookmarkManager.shared.add(coinID: coinId)
            }
        } catch {
            print(error)
        }
    }
}
