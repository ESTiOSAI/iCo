//
//  LLMResponseDTO.swift
//  iCo
//
//  Created by 강대훈 on 9/15/25.
//

import Foundation

struct LLMResponseDTO: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
        
        struct Content: Codable {
            let parts: [Part]
            
            struct Part: Codable {
                let text: String
            }
        }
    }
}
