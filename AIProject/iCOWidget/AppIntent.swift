//
//  AppIntent.swift
//  iCOWidget
//
//  Created by 백현진 on 9/18/25.
//

import AppIntents
import WidgetKit

struct CoinWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "코인 선택" }
    static var description = IntentDescription("북마크한 코인 중 위젯에 표시할 코인을 선택하세요.")

    @Parameter(title: "코인1")
    var firstCoin: CoinAppEntity?          // Small/Medium/Large 모두 사용

    @Parameter(title: "코인2")
    var secondCoin: CoinAppEntity?         // Large일 때만 사용

    static var parameterSummary: some ParameterSummary {
        Summary("첫번째: \(\.$firstCoin), 두번째: \(\.$secondCoin)")
    }
}

struct CoinAppEntity: AppEntity, Hashable, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "코인" }
    static var defaultQuery = DefaultQuery()

    var id: String
    var koreanName: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: .init(stringLiteral: koreanName),
                              subtitle: .init(stringLiteral: id))
    }

    struct DefaultQuery: EntityQuery {
        private let suite = AppGroup.suite

        func suggestedEntities() async throws -> [CoinAppEntity] {
            let defaults = UserDefaults(suiteName: suite)
            
            guard let dict = defaults?.dictionary(forKey: "widgetBookmarks") as? [String: String] else {
                return []
            }

            return dict.map { CoinAppEntity(id: $0.key, koreanName: $0.value) }
        }

        func entities(for identifiers: [String]) async throws -> [CoinAppEntity] {
            let all = try await suggestedEntities()
            return all.filter { identifiers.contains($0.id) }
        }
    }
}
