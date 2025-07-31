//
//  AlanAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 앨런 API 관련 서비스를 제공합니다.
final class AlanAPIService {
    private let CLIENT_ID = "" // MARK: 아마 xcconfig를 통해서 개인 키 관리가 필요할 거 같습니다.
    private let network: NetworkClient
    private let endpoint: String = "https://kdt-api-function.azurewebsites.net/api/v1/question"

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    /// 입력한 질문 또는 문장에 대한 응답을 가져옵니다.
    /// - Parameter content: 질문 또는 분석할 문장
    /// - Returns: 수신한 응답 데이터
    func fetchAnswer(content: String) async throws -> AlanResponseDTO {
        let urlString = "\(endpoint)?content=\(content)&client_id=\(CLIENT_ID)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let alanResponseDTO: AlanResponseDTO = try await network.request(url: url)

        return alanResponseDTO
    }
}
