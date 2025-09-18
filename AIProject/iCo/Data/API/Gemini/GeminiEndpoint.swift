//
//  GeminiEndpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

enum GeminiEndpoint {
    case main(body: Encodable, action: LLMAction)
}

extension GeminiEndpoint: Requestable {
    var baseURL: String { "https://generativelanguage.googleapis.com" }
    var path: String { "/v1beta/models/gemini-2.5-flash-lite:generateContent" }
    var httpMethod: HTTPMethod { .post }
    var queryParameters: Encodable? { nil }
    
    var bodyParameters: Encodable? {
        switch self {
        case .main(let body, _):
            return body
        }
    }
    
    var headers: [String : String] {
        guard let clientID = switchClientID(for: getAction()) else {
            return [:]
        }
        
        return [
            "Content-Type": "application/json",
            "X-goog-api-key": clientID
        ]
    }
    
    private func getAction() -> LLMAction {
        switch self {
        case .main(_, let action):
            return action
        }
    }
    
    private func switchClientID(for action: LLMAction) -> String? {
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
