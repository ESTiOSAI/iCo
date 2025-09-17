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
    
    /// 업비트 코인 목록과 대조를 거친 최종 코인의 배열
    @Published var verifiedCoinList = Set<CoinDTO>()
    
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
                    $0.coinID.replacingOccurrences(of: "KRW-", with: "").lowercased(), // 마켓 이름을 제외한 코인 심볼을 사용하기
                    $0.koreanName,
                    $0.englishName.lowercased()
                ]})
                
                // 이미지에서 텍스트 읽어오기
                try Task.checkCancellation()
                let recognizedText = try await performOCR(from: selectedImage, with: coinNameSet)
                guard !recognizedText.isEmpty else {
                    throw ImageProcessError.noRecognizedText
                }
                print("➡️ recognizedText: ", recognizedText)
                
                // 읽어온 텍스트에서 코인 이름을 추출하기
                try Task.checkCancellation()
                try convertToSymbol(from: recognizedText)
                guard !verifiedCoinList.isEmpty else {
                    throw ImageProcessError.noExtractedCoinID
                }
                print("➡️ verifiedCoinList: ", verifiedCoinList)
                
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
            let recognizedText = try await TextRecognitionHelper()
                .handleOCR(
                    from: ocrImage,
                    with: coinNames
                )
            
            return recognizedText
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw ImageProcessError.unknownVisionError
        }
    }
    
    /// 전달받은 문자열 배열과 CoinDTO를 매핑하고 verifiedCoinList를 업데이트하는 함수
    private func convertToSymbol(from text: [String]) throws {
        guard let coinList else {
            throw ImageProcessError.noCoinFetched
        }
        
        // 빠른 검색을 위해 키가 String, 값이 CoinDTO인 딕셔너리 만들기
        var lookup: [String: CoinDTO] = [:]
        for coin in coinList {
            lookup[coin.coinID.replacingOccurrences(of: "KRW-", with: "").lowercased()] = coin
            lookup[coin.koreanName] = coin
            lookup[coin.englishName.lowercased()] = coin
        }
        
        // 딕셔너리와 CoinDTO를 매핑하기
        let mappedCoins = text.compactMap { lookup[$0] }
        
        // Set에 삽입하기
        for coin in mappedCoins {
            verifiedCoinList.insert(coin)
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
