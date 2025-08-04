//
//  BookmarkView.swift
//  AIProject
//
//  Created by 백현진 on 8/1/25.
//

import SwiftUI

struct BookmarkView: View {
    //@StateObject var vm = BookmarkViewModel()

    @State private var selectedCategory: SortCategory? = nil
    @State private var nameOrder: SortOrder = .none
    @State private var priceOrder: SortOrder = .none
    @State private var volumeOrder: SortOrder = .none

    @State var investmentBrief: String = "요약문 이어서~"
    @State var strategySuggestion: String = "전략 제안 이어서~"

    @State private var didCopy = false

    // 더미 데이터
    var allCoins = CoinListModel.preview

    // 정렬 데이터
    var sortedCoins: [CoinListModel] {
        switch selectedCategory{
        case .name:
            switch nameOrder {
            case .ascending:
                return allCoins.sorted { $0.name < $1.name }
            case .descending:
                return allCoins.sorted { $0.name > $1.name }
            case .none:
                return allCoins
            }

        case .price:
            switch priceOrder {
            case .ascending:
                return allCoins.sorted { $0.currentPrice < $1.currentPrice }
            case .descending:
                return allCoins.sorted { $0.currentPrice > $1.currentPrice }
            case .none:
                return allCoins
            }

        case .volume:
            switch volumeOrder {
            case .ascending:
                return allCoins.sorted { $0.tradeAmount < $1.tradeAmount }
            case .descending:
                return allCoins.sorted { $0.tradeAmount > $1.tradeAmount }
            case .none:
                return allCoins
            }

        case .none:
            return allCoins
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {

                HeaderView(heading: "북마크 관리", isBookmarkView: true)
                    .padding(.bottom, 16)
                SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")

                // 북마크 AI 한줄평
                VStack(alignment: .leading, spacing: 8) {
                    Text("📝투자 브리핑 요약")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)

                    Text(investmentBrief)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("✅전략 제안")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)

                    Text(strategySuggestion)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.leading, 16).padding(.trailing, 16).padding(.bottom, 24)
                .overlay(alignment: .topTrailing) {
                    Button {
                        didCopy = true

                        // 클립 보드에 복사
                        UIPasteboard.general.string = investmentBrief + "\n\n" + strategySuggestion

                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            didCopy = false
                        }
                    } label: {
                        Image(systemName: didCopy ? "checkmark.circle" : "doc.on.doc")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                            .padding(24)
                            .padding(.top, -16)
                    }
                }

                HStack {
                    Image(systemName: "bookmark.fill")

                    Text("북마크 코인")
                        .font(.system(size: 15))

                    Spacer()

                    Button {

                    } label: {
                        Text("전체 삭제")
                            .font(.system(size: 12)).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .foregroundStyle(.gray)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)

                Divider()

                LazyVStack(spacing: 8) {
                    HStack {
                        SortToggleButton(
                            title: "코인명",
                            sortCategory: .name,
                            currentCategory: $selectedCategory,
                            sortOrder: $nameOrder
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: selectedCategory) { _, newKey in
                            if newKey != .name { nameOrder = .none }
                        }

                        SortToggleButton(
                            title: "현재가/변동",
                            sortCategory: .price,
                            currentCategory: $selectedCategory,
                            sortOrder: $priceOrder
                        )
                        .frame(width: 100, alignment: .trailing)
                        .onChange(of: selectedCategory) { _, newKey in
                            if newKey != .price { priceOrder = .none }
                        }

                        SortToggleButton(
                            title: "거래대금",
                            sortCategory: .volume,
                            currentCategory: $selectedCategory,
                            sortOrder: $volumeOrder
                        )
                        .frame(width: 100, alignment: .trailing)
                        .onChange(of: selectedCategory) { _, newKey in
                            if newKey != .volume { volumeOrder = .none }
                        }

                    }
                    .padding(.leading, 16).padding(.trailing, 16)
                    .fontWeight(.regular)
                    .font(.system(size: 12))
                    .foregroundStyle(.aiCoLabel)


                    Divider()

                    ForEach(sortedCoins) { coin in
                        NavigationLink {
                            MockDetailView(coin: coin)
                        } label: {
                            CoinRowView(coin: coin)
                        }
                    }
                }
            }
        }

    }

}

#Preview {
    BookmarkView()
}
