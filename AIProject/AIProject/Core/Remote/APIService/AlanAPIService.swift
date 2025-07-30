//
//  AlanAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

final class AlanAPIService {
    private let CLIENT_ID = "" //MARK: 아마 xcconfig를 통해서 키 관리가 필요할 거 같습니다.
    private let network: NetworkClient
    private let endpoint: String = "https://kdt-api-function.azurewebsites.net/api/v1/question"

    init(networkClient: NetworkClient) {
        self.network = networkClient
    }

    func fetchAnswer(content: String) async throws -> AlanResponseDTO {
        let urlString = "\(endpoint)?content=\(content)&client_id=\(CLIENT_ID)"
        let alanResponseDTO: AlanResponseDTO = try await network.request(url: URL(string: urlString)!)

        return alanResponseDTO
    }
}
