//
//  GeminiAPIService.swift
//  iCo
//
//  Created by 강대훈 on 9/15/25.
//

import Foundation

final class GeminiAPIService {
    private let network: NetworkClient
    private let urlString: String = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"
    
    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }
    
    func postAnswer(content: String, action: AlanAction) async throws -> LLMResponseDTO {
        guard let clientID = switchClientID(for: .coinRecomendation) else {
            throw NetworkError.invalidAPIKey
        }
        
        let postBody = LLMRequestBody(
            contents: [
                LLMRequestBody.Content(
                    parts: [
                        LLMRequestBody.Content.Part(text: "안녕 오늘 하루는 어때?")
                    ]
                )
            ]
        )
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let jsonData = try JSONEncoder().encode(postBody)
            
            let endpoint = Endpoint(
                path: url,
                method: .post,
                headers: ["Content-Type": "application/json", "X-goog-api-key": clientID],
                body: jsonData
            )
            
            let responseDTO: LLMResponseDTO = try await network.postRequest(to: endpoint)
            print(responseDTO.candidates.first!.content.parts.first!.text)
            return responseDTO
        } catch {
            throw error
        }
    }
}

extension GeminiAPIService {
    private func switchClientID(for action: AlanAction) -> String? {
        switch action {
        case .coinRecomendation:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_RECOMENDATION"] as? String
        case .dashboardBriefingGeneration:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_AI_BRIEFING_GENERATION"] as? String
        case .coinReportGeneration:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_REPORT_GENERATION"] as? String
        case .coinIDExtraction:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_ID_EXTRACTION"] as? String
        case .bookmarkSuggestion:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_BOOKMARK_SUGGESTION"] as? String
        }
    }
}
