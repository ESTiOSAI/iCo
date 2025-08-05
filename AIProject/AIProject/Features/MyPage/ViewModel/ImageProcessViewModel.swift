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
    
    @Published var showErrorMessage = false
    @Published var errorMessage = ""
    
    @Published var verifiedCoinIDs = [String]()
    
    /// 북마크 대량 등록을 위해 이미지에 대한 비동기 처리를 컨트롤하는 함수
    func processImage(from selectedImage: UIImage) {
        Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                // 이미지에서 텍스트 읽어오기
                let recognizedText = try await performOCR(from: selectedImage)
                guard !recognizedText.isEmpty else {
                    print("ℹ️ OCR 처리 결과 : \(recognizedText)")
                    throw ImageProcessError.noRecognizedText
                }
                
                // 읽어온 텍스트에서 코인 이름을 추출하기
                let convertedSymbols = try await convertToSymbol(with: recognizedText)
                guard !convertedSymbols.isEmpty else {
                    print("ℹ️ OCR 처리 결과 : \(recognizedText)")
                    print("ℹ️ Alan 응답 : \(convertedSymbols)")
                    throw ImageProcessError.noExtractedCoinID
                }
                
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
            } catch let error as ImageProcessError {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.message
                    self.showErrorMessage = true
                }
                print("🚨 이미지 처리 중 에러 발생:", error)
            }
        }
    }
    
    /// 전달된 이미지에 OCR을 처리하고 비식별화된 문자열 배열을 받아오는 함수
    func performOCR(from selectedImage: UIImage) async throws -> [String] {
        do {
            let recognizedText = try await TextRecognitionHelper.recognizeText(from: selectedImage)
            
            return recognizedText
        } catch {
            print(#function)
            throw ImageProcessError.unknownVisionError
        }
    }
    
    // TODO: 인식한 텍스트 주변에 박스 그리기
    
    /// Alan을 이용해 전달받은 문자열 배열에서 coinID를 추출하는 함수
    func convertToSymbol(with text: [String]) async throws -> [String] {
        do {
            let answer = try await AlanAPIService().fetchAnswer(content: """
            아래의 문자열 배열에서 가상화폐의 이름을 찾아. 응답에는 다른 설명 없이 빈 배열에 해당 코인의 영문 심볼들만 담아서 반환해. 오타가 있다면 고쳐주고 "," 로 구분해.
            \(text)
            """, action: .coinIDExtraction)
            
            let convertedSymbols = answer.content.extractedJSON
                .replacingOccurrences(of: "\"", with: "") // "\" 문자 제거하기
                .components(separatedBy: ",") // "," 기준으로 나누기
            
            return convertedSymbols
        } catch {
            print(#function)
            print("ℹ️ 프롬프트 :", Prompt.extractCoinID(text: textString).content)
            throw ImageProcessError.unknownAlanError
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
