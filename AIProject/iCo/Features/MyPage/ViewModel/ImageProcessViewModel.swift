//
//  ImageProcessViewModel.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

/// 북마크 대량 등록 관련 작업들을 처리하는 뷰모델
class ImageProcessViewModel: ObservableObject {
    /// 업비트에서 받아온 한국 마켓의 코인들을 담는 배열
    /// 1 ) 뷰 생성 시 fetch 한 후 OCR 비식별화 단계에서 사용, 2 ) CoreData 삽입 직전에 더블 체크용으로 사용
    @Published var coinList: [CoinDTO]?
    
    /// 비동기 작업 흐름 제어를 위한  Task
    @Published var processImageTask: Task<Void, Error>?
    
    /// 이미지 처리 상태를 담는 변수
    @Published var isLoading = false
    
    /// 이미지 처리 성공 시, 처리 결과를 알려주는 Alert 의 상태를 제어하는 변수
    @Published var showAnalysisResultAlert = false
    
    /// 이미지 실패 시, 처리 결과를 알려주는 Alert 의 상태와 메시지를 제어하는 변수
    @Published var showErrorMessage = false
    @Published var errorMessage = ""
    
    /// Alan 식별 + 업비트 검증을 거친 최종 코인의 배열
    @Published var verifiedCoinList = [CoinDTO]()
    
    /// 북마크 대량 등록을 위해 이미지에 대한 비동기 처리를 컨트롤하는 함수
    func processImage(from selectedImage: CGImage) {
        processImageTask = Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                guard let coinList else {
                    throw ImageProcessError.noCoinFetched
                }
                
                // 코인 이름 Set 으로 변환하기
                let coinNameSet: Set<String> = Set(coinList.flatMap {[
                    String($0.coinID[$0.coinID.index($0.coinID.startIndex, offsetBy: 4)...].lowercased()), // 마켓 이름을 제외한 코인 심볼을 사용하기
                    $0.koreanName,
                    $0.englishName.lowercased()
                ]})
                
                // 이미지에서 텍스트 읽어오기
                try Task.checkCancellation()
                let recognizedText = try await performOCR(from: selectedImage, with: coinNameSet)
                guard !recognizedText.isEmpty else {
                    throw ImageProcessError.noRecognizedText
                }
                
                // 읽어온 텍스트에서 코인 이름을 추출하기
                try Task.checkCancellation()
                let convertedSymbols = try await convertToSymbol(with: recognizedText)
                guard !convertedSymbols.isEmpty else {
                    throw ImageProcessError.noExtractedCoinID
                }
                
                // 업비트 코인 리스트에 포함된 coinID만 배열에 담기
                try Task.checkCancellation()
                for symbol in convertedSymbols {
                    do {
                        try await verifyAndAppend(symbol: symbol)
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        continue
                    }
                }
                
                // 최종 리스트가 비어있을 경우
                if verifiedCoinList.isEmpty {
                    throw ImageProcessError.noExistingCoin
                } else {
                    await showAnalysisResult()
                }
            } catch is CancellationError {
                await terminateProcess()
            } catch let error as ImageProcessError {
                await terminateProcess(with: error)
            }
        }
    }
    
    @MainActor
    func cancelTask() {
        processImageTask?.cancel()
    }
    
    @MainActor
    private func showAnalysisResult() {
        isLoading = false
        showAnalysisResultAlert = true
    }
    
    @MainActor
    private func terminateProcess(with error: ImageProcessError? = nil) {
        isLoading = false
        
        if let error {
            errorMessage = error.description
            showErrorMessage = true
        }
    }
    
    func fetchCoinList() async throws -> [CoinDTO] {
        return try await UpBitAPIService().fetchMarkets()
    }
    
    /// 전달된 이미지에 OCR을 처리하고 비식별화된 문자열 배열을 받아오는 함수
    private func performOCR(from selectedImage: CGImage, with coinNames: Set<String>) async throws -> [String] {
        var ocrImage: CGImage? = selectedImage
        
        try Task.checkCancellation()
        
        defer {
            ocrImage = nil
        }
        
        do {
            guard let ocrImage else { return [String]() }
            let recognizedText = try await TextRecognitionHelper(image: ocrImage, coinNames: coinNames).handleOCR()
            
            return recognizedText
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw ImageProcessError.unknownVisionError
        }
    }
    
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
            
            // Alan이 간헐적으로 JSON에 담아서 내려주는 경우에 대응
            if answerContent.starts(with: "```json") {
                answerContent = answerContent.extractedJSON
            }
            
            let convertedSymbols = answerContent.convertIntoArray
            
            return convertedSymbols
        } catch let error as NetworkError {
            switch error {
            case .taskCancelled:
                throw CancellationError()
            default:
                print(error.log())
                throw ImageProcessError.unknownAlanError
            }
        }
    }
    
    /// 업비트 API를 호출해 coinID가 실제로 존재하는지 검증, 검증된 coinID를 배열에 저장하는 함수
    private func verifyAndAppend(symbol: String) async throws {
        try Task.checkCancellation()
        
        // 한국 마켓만 사용하므로 한국 마켓 이름 추가하기
        let krwSymbolName = "KRW-\(symbol.uppercased())"
        
        if let coinList {
            await MainActor.run {
                verifiedCoinList.append(contentsOf: coinList.filter { $0.coinID == krwSymbolName })
            }
        }
    }
    
    // CoreData에 coinID를 일괄 삽입하는 함수
    func addToBookmark() {
        do {
            for coin in verifiedCoinList {
                try BookmarkManager.shared.add(coinID: coin.coinID, coinKoreanName: coin.koreanName)
            }
        } catch {
            print(error)
        }
    }
    
    deinit {
        print("vm", #function)
    }
}
