//
//  LLMRequestBody.swift
//  iCo
//
//  Created by 강대훈 on 9/15/25.
//


struct LLMRequestBody: Codable {
    let contents: [Content]
    
    struct Content: Codable {
        let parts: [Part]
        
        struct Part: Codable {
            let text: String
        }
    }
}