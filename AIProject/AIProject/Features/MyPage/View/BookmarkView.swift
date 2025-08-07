//
//  BookmarkView.swift
//  AIProject
//
//  Created by 백현진 on 8/1/25.
//

import SwiftUI

struct BookmarkView: View {
    @StateObject var vm = BookmarkViewModel()

    @State private var selectedCategory: SortCategory? = nil
    @State private var nameOrder: SortOrder = .none
    @State private var priceOrder: SortOrder = .none
    @State private var volumeOrder: SortOrder = .none

    @State private var isShowingShareSheet = false
    @State private var sharingImage: UIImage?

    // 정렬 데이터
    var sortedCoins: [BookmarkEntity] {
        switch selectedCategory{
        case .name:
            switch nameOrder {
            case .ascending:
                return vm.bookmarks.sorted { $0.coinKoreanName < $1.coinKoreanName }
            case .descending:
                return vm.bookmarks.sorted { $0.coinKoreanName > $1.coinKoreanName }
            case .none:
                return vm.bookmarks
            }

        case .none:
            return vm.bookmarks
        }
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HeaderView(heading: "북마크 관리", isBookmarkView: true)
                    .padding(.bottom, 16)

                HStack {
                    SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")

                }
                // 북마크 AI 한줄평
                BriefingSectionView(briefing: vm.briefing, isLoading: vm.isLoading, bookmarksEmpty: vm.isBookmarkEmpty, errorMessage: vm.errorMessage)

//                Button("내보내기") {
//                    vm.exportBriefingImage()
//                }

                HStack {
                    Image(systemName: "bookmark.fill")

                    Text("북마크 코인")
                        .font(.system(size: 15))

                    Spacer()

                    RoundedButton(title: "전체 삭제") {
                        print("전체 삭제")
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)

                Divider()

                // 코인 리스트뷰
                CoinListSectionView(
                    sortedCoins: sortedCoins,
                    selectedCategory: $selectedCategory,
                    nameOrder: $nameOrder,
                    priceOrder: $priceOrder,
                    volumeOrder: $volumeOrder
                )
            }
        .task {
            await vm.loadBriefing(character: .longTerm)
        }
    }
}

struct BriefingSectionView: View {
    let briefing: PortfolioBriefingDTO?
    let isLoading: Bool
    let bookmarksEmpty: Bool
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if bookmarksEmpty {
                Text("코인을 북마크 해보세요!")
            } else if isLoading {
                DefaultProgressView(
                    message: "분석중...",
                    font: .caption2,
                    spacing: 8
                )
            } else if let briefing {
                BadgeLabelView(text: "📝 투자 브리핑 요약")
                Text(briefing.briefing)
                    .font(.system(size: 12))

                Spacer(minLength: 0)

                BadgeLabelView(text: "✅ 전략 제안")
                Text(briefing.strategy)
                    .font(.system(size: 12))
            } else if let errorMessage {
                Text("예상치 못한 에러 발생: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.primary)
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}


#Preview {
    BookmarkView()
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
