//
//  iCOWidget.swift
//  iCOWidget
//
//  Created by 백현진 on 9/18/25.
//

import WidgetKit
import SwiftUI

//MARK: - TimeLineEntry

struct CoinEntry: TimelineEntry {
    let date: Date
    let coins: [WidgetCoinSummary]
}

//MARK: - Provider
struct CoinProvider: AppIntentTimelineProvider {
    private let suite = AppGroup.suite
    private let api = UpBitWidgetAPI()

    func placeholder(in context: Context) -> CoinEntry {
        CoinEntry(date: Date(), coins: sampleData)
    }

    func snapshot(for configuration: CoinWidgetConfigurationIntent,
                  in context: Context) async -> CoinEntry {
        await loadEntry(configuration: configuration, family: context.family)
    }
    
    func timeline(for configuration: CoinWidgetConfigurationIntent,
                  in context: Context) async -> Timeline<CoinEntry> {
        
        let entry = await loadEntry(configuration: configuration, family: context.family)
        let next = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        return Timeline(entries: [entry], policy: .after(next))
    }

    // MARK: - Helpers

    /// UserDefaults에서 [북마크된 코인 ID : 한국이름] 불러오기
    private func loadBookmarkDict() -> [String: String] {
        let defaults = UserDefaults(suiteName: suite)
        return defaults?.dictionary(forKey: AppStorageKey.widgetBookmarks) as? [String: String] ?? [:]
    }
    
    private func loadEntry(configuration: CoinWidgetConfigurationIntent,
                           family: WidgetFamily) async -> CoinEntry {
        let bookmarkDict = loadBookmarkDict()
        guard !bookmarkDict.isEmpty else {
            return CoinEntry(date: Date(), coins: [])
        }

        var summaries: [WidgetCoinSummary] = []

        await withTaskGroup(of: WidgetCoinSummary?.self) { group in
            for (id, name) in bookmarkDict {
                group.addTask {
                    do {
                        // 현재 시세
                        guard let ticker = try await api.fetchQuotes(id: id) else { return nil }
                        // 최근 캔들
                        let candles = try await api.fetchCandles(id: id, count: 10)
                        let history = candles.map { $0.tradePrice }.reversed()

                        return WidgetCoinSummary(
                            id: id,
                            koreanName: name,
                            price: ticker.tradePrice,
                            change: ticker.signedChangeRate * 100,
                            history: Array(history)
                        )
                    } catch {
                        print("위젯 네트워크 실패: \(error)")
                        return nil
                    }
                }
            }

            for await summary in group {
                if let s = summary { summaries.append(s) }
            }
        }

        let picked = filterSummaries(all: summaries,
                                     configuration: configuration,
                                     family: family)

        return CoinEntry(date: Date(), coins: picked)
    }

    private func filterSummaries(all: [WidgetCoinSummary],
                                 configuration: CoinWidgetConfigurationIntent,
                                 family: WidgetFamily) -> [WidgetCoinSummary] {
        let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

        var picked: [WidgetCoinSummary] = []
        if let first = configuration.firstCoin?.id,
            let s1 = byID[first] {
            picked.append(s1)
        }
        if family == .systemLarge,
           let second = configuration.secondCoin?.id,
           second != configuration.firstCoin?.id,
           let s2 = byID[second] {
            picked.append(s2)
        }

        let needed = maxCount(for: family) - picked.count
        if needed > 0 {
            let remaining = all.filter { c in !picked.contains(where: { $0.id == c.id }) }
            picked.append(contentsOf: remaining.prefix(needed))
        }

        return Array(picked.prefix(maxCount(for: family)))
    }

    private func maxCount(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:  return 1
        case .systemMedium: return 1
        case .systemLarge:  return 2
        default:            return 1
        }
    }

    // 샘플(프리뷰/대체)
    private var sampleData: [WidgetCoinSummary] {
        [
            .init(id: "KRW-BTC", koreanName: "비트코인",
                  price: 102_300_000, change: 2.3,
                  history: [101_000_000, 102_000_000, 103_000_000, 102_800_000]),
            .init(id: "KRW-ETH", koreanName: "이더리움",
                  price: 3_800_000, change: -1.1,
                  history: [3_700_000, 3_850_000, 3_800_000, 3_790_000])
        ]
    }
}

//MARK: - CoinWidgetEntryView
struct CoinWidgetEntryView: View {
    var entry: CoinProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                if let coin = entry.coins.first {
                    CoinCardView(coin: coin, date: entry.date)
                } else { emptyView }

            case .systemMedium:
                if let coin = entry.coins.first {
                    CoinCardView(coin: coin, date: entry.date)
                } else { emptyView }

            case .systemLarge:
                VStack(spacing: 0) {
                    if let first = entry.coins.first {
                        CoinCardView(coin: first, date: entry.date)
                    }

                    if entry.coins.count > 1 {
                        Divider()
                            .background(Color.aiCoBorderGray)
                            .padding(.vertical, 8)
                        CoinCardView(coin: entry.coins[1], date: entry.date)
                    }
                }

            default:
                if let coin = entry.coins.first {
                    CoinCardView(coin: coin, date: entry.date)
                } else { emptyView }
            }
        }
        .containerBackground(.aiCoBackground, for: .widget)
    }

    private var emptyView: some View {
        Text("선택된 코인 없음")
            .font(.system(size: 10))
            .foregroundColor(.aiCoLabelSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//MARK: - CoinWidget
@main
struct CoinWidget: Widget {
    private let kind = "CoinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: CoinWidgetConfigurationIntent.self,
                               provider: CoinProvider()) { entry in
            CoinWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("북마크 코인 선택")
        .description("Small, Medium 크기의 위젯은 코인 1개\nLarge크기는 코인 2개를 표시합니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

//MARK: - CoinCardView
struct CoinCardView: View {
    let coin: WidgetCoinSummary
    let date: Date

    @Environment(\.widgetFamily) private var family
    private var isSmall: Bool { family == .systemSmall }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(coin.koreanName)
                        .font(.system(size: isSmall ? 10 : 12, weight: .semibold))
                        .foregroundColor(.aiCoLabel)

                    Text(coin.symbol)
                        .font(.system(size: isSmall ? 10 : 12))
                        .foregroundColor(.aiCoLabelSecondary)
                }

                HStack(spacing: 0) {
                    if !isSmall {
                        Text("업데이트: ")
                            .font(.system(size: 10))
                    }
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: isSmall ? 8 : 10))
                }
                .foregroundColor(.aiCoLabelSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            }

            SparklineView(prices: coin.history)
                .padding(8)

            HStack {
                Text(coin.price.formatKRW)
                    .font(.system(size: 10))
                    .foregroundColor(.aiCoLabel)
                Spacer()

                Text("\(coin.change, specifier: "%.2f")%")
                    .font(.system(size: 10)).bold()
                    .foregroundColor(coin.change >= 0 ? .aiCoPositive : .aiCoNegative)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SparklineView: View {
    let prices: [Double]

    private var normalized: [CGFloat] {
        guard prices.count > 1 else { return [] }
        guard let min = prices.min(), let max = prices.max(), min != max else {
            return Array(repeating: 0.5, count: prices.count)
        }
        return prices.map { CGFloat(($0 - min) / (max - min)) }
    }

    var body: some View {
        GeometryReader { geo in
            if normalized.isEmpty {
                Path { path in
                    let midY = geo.size.height / 2
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: geo.size.width, y: midY))
                }
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            } else {
                ZStack {
                    Path { path in
                        for (index, value) in normalized.enumerated() {
                            let x = geo.size.width * CGFloat(index) / CGFloat(normalized.count - 1)
                            let y = geo.size.height * (1 - value)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.aiCoAccent, style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                    if let last = normalized.last {
                        let x = geo.size.width
                        let y = geo.size.height * (1 - last)

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
        }
        //.frame(height: 36)
    }
}
