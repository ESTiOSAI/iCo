//
//  AppIntent.swift
//  CoinWidget
//
//  Created by 백현진 on 8/26/25.
//
import AppIntents
import WidgetKit

struct CoinWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "코인 선택" }
    static var description = IntentDescription("북마크한 코인 중 위젯에 표시할 코인을 선택하세요.")

    @Parameter(title: "첫번째 코인")
    var firstCoin: CoinAppEntity?          // Small/Medium/Large 모두 사용

    @Parameter(title: "두번째 코인 (Large 전용)")
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
        private let suite = "group.com.est.aico"

        func suggestedEntities() async throws -> [CoinAppEntity] {
            let defaults = UserDefaults(suiteName: suite)
            guard let data = defaults?.data(forKey: "widgetSummary"),
                  let items = try? JSONDecoder().decode([WidgetCoinSummary].self, from: data) else {
                return []
            }
            return items.map { CoinAppEntity(id: $0.id, koreanName: $0.koreanName) }
        }

        func entities(for identifiers: [String]) async throws -> [CoinAppEntity] {
            let all = try await suggestedEntities()
            return all.filter { identifiers.contains($0.id) }
        }
    }
}
