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
    
    @Published var processImageTask: Task<Void, Error>?
    
    /// 북마크 대량 등록을 위해 이미지에 대한 비동기 처리를 컨트롤하는 함수
    func processImage(from selectedImage: UIImage) {
        processImageTask = Task {
            await MainActor.run { self.isLoading = true }
            
            do {
                // 이미지에서 텍스트 읽어오기
                try Task.checkCancellation()
                let recognizedText = try await performOCR(from: selectedImage)
                guard !recognizedText.isEmpty else {
                    throw ImageProcessError.noRecognizedText
                }
                
                // 읽어온 텍스트에서 코인 이름을 추출하기
                try Task.checkCancellation()
                let convertedSymbols = try await convertToSymbol(with: recognizedText)
                guard !convertedSymbols.isEmpty else {
                    print("ℹ️ OCR 처리 결과 :", recognizedText)
                    print("ℹ️ Alan 응답 :", convertedSymbols)
                    throw ImageProcessError.noExtractedCoinID
                }
                
                // 업비트 API 호출 테스트로 검증된 coinID만 배열에 담기
                try Task.checkCancellation()
                for symbol in convertedSymbols {
                    do {
                        try await verifyAndAppend(symbol: symbol)
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        print("ℹ️ 업비트 API 호출 테스트 :", symbol)
                        throw ImageProcessError.noMatchingCoinIDAtAPI
                    }
                }

                print("🚀 최종 코인 목록 :", verifiedCoinIDs)
                await showAnalysisResult()
                
            } catch is CancellationError {
                await showError(.canceled)
            } catch let error as ImageProcessError {
                await showError(error)
            }
        }
    }
    
    @MainActor
    func cancelTask() {
        self.processImageTask?.cancel()
    }
    
    @MainActor
    private func showAnalysisResult() {
        self.isLoading = false
        self.showAnalysisResultAlert = true
    }
    
    @MainActor
    private func showError(_ error: ImageProcessError) {
        self.isLoading = false
        self.errorMessage = error.description
        self.showErrorMessage = true
        print("🚨 이미지 처리 중 에러 발생:", error)
    }
    
    /// 전달된 이미지에 OCR을 처리하고 비식별화된 문자열 배열을 받아오는 함수
    private func performOCR(from selectedImage: UIImage) async throws -> [String] {
        try Task.checkCancellation()
        
        do {
            let recognizedText = try await TextRecognitionHelper.recognizeText(from: selectedImage)
            
            return recognizedText
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            print(#function)
            throw ImageProcessError.unknownVisionError
        }
    }
    
    // TODO: 인식한 텍스트 주변에 박스 그리기
    
    /// Alan을 이용해 전달받은 문자열 배열에서 coinID를 추출하는 함수
    private func convertToSymbol(with text: [String]) async throws -> [String] {
        let textString = text.description
        let prompt = Prompt.extractCoinID(text: textString).content
        
        do {
            try Task.checkCancellation()
            
            let answer = try await AlanAPIService().fetchAnswer(
                content: prompt,
                action: .coinIDExtraction
            )
            
            var answerContent = answer.content
            
#if DEBUG
            print("ℹ️ 앨런 프롬프트 :", prompt)
            print("ℹ️ 앨런 응답 :", answerContent)
#endif
            
            // Alan이 간헐적으로 JSON에 담아서 내려주는 경우에 대응
            if answerContent.starts(with: "```json") {
                answerContent = answerContent.extractedJSON
            }
            
            let convertedSymbols = answerContent.convertIntoArray

#if DEBUG
            print("ℹ️ 파싱 후 :", convertedSymbols)
#endif
            
            return convertedSymbols
        } catch let error as URLError {
            // 네트워크 작업에서 사용자가 작업을 취소하는 경우 CancellationError가 아닌 URLError로 넘어오기 때문에
            // URLError로 타입 캐스팅하고 code 값으로 분기해서 에러를 상위 제어로 던짐
            if error.code == .cancelled {
                throw CancellationError()
            }
            
            print("ℹ️ 프롬프트 :", Prompt.extractCoinID(text: textString).content)
            throw ImageProcessError.unknownAlanError
        }
    }
    
    /// 업비트 API를 호출해 coinID가 실제로 존재하는지 검증, 검증된 coinID를 배열에 저장하는 함수
    private func verifyAndAppend(symbol: String) async throws {
        try Task.checkCancellation()
        
        // 한국 마켓만 사용하므로 한국 마켓 이름 추가하기
        let krwSymbolName = "KRW-\(symbol)"
        
        do {
            let verified = try await UpBitAPIService().verifyCoinID(id: krwSymbolName)
            
            if verified {
                await MainActor.run {
                    self.verifiedCoinIDs.append(krwSymbolName)
                }
            }
        } catch let error as URLError {
            if error.code == .cancelled {
                throw CancellationError()
            }
            print(error)
        }
    }
    
    // CoreData에 coinID를 일괄 삽입하는 함수
    func addToBookmark() {
        print("To Be Handled in the following PR")
        //do {
            //for coinId in verifiedCoinIDs {
                //try BookmarkManager.shared.add(coinID: coinId)
            //}
        //} catch {
            //print(error)
        //}
    }
}
