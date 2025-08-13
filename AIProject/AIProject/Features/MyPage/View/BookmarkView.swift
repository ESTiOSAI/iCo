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
    @State private var sharingItems: [Any] = []
    @State private var showingExportOptions = false
    @State private var showDeleteConfirm = false

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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                HeaderView(heading: "북마크 관리", isBookmarkView: true, onExportTap: {
                    guard !(vm.isBookmarkEmpty || vm.briefing == nil || vm.isLoading) else { return }
                    showingExportOptions = true
                }
                )
                .padding(.bottom, 16)

                HStack {
                    SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")
                }

                // 북마크 AI 한줄평
                BriefingSectionView(briefing: vm.briefing, isLoading: vm.isLoading, bookmarksEmpty: vm.isBookmarkEmpty, errorMessage: vm.errorMessage)

                HStack(spacing: 2) {
                    Image(systemName: "info.circle")
                    Text("해당 컨텐츠는 생성형 AI의 응답으로 오류가 있을 수 있습니다.")
                }
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)

                Spacer()

                HStack {
                    SubheaderView(subheading: "북마크한 코인")
 
                    Spacer()

                    RoundedButton(title: "전체 삭제") {
                        showDeleteConfirm = true
                    }.alert("전체 북마크 삭제", isPresented: $showDeleteConfirm) {
                        Button("삭제", role: .destructive) {
                            vm.deleteAllBookmarks()
                        }
                        Button("취소", role: .cancel) { }
                    } message: {
                        Text("모든 북마크를 삭제하시겠습니까?")
                    }
                }
                .padding(.trailing, 16)

                Divider()

                if sortedCoins.isEmpty {
                    Text("북마크한 코인이 없습니다 🥵")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    CoinListSectionView(
                        sortedCoins: sortedCoins,
                        selectedCategory: $selectedCategory,
                        nameOrder: $nameOrder,
                        priceOrder: $priceOrder,
                        volumeOrder: $volumeOrder,
                        imageURLProvider: { vm.imageURL(for: $0) },
                        onDelete: { vm.deleteBookmark($0) }
                    )
                    .padding()
                }
            }
            .onAppear {
                Task {
                    async let imagesTask: () = vm.loadCoinImages()
                    async let briefingTask: () = vm.loadBriefing(character: .longTerm)
                    await briefingTask
                    await imagesTask
                }
            }
            // 북마크 심볼 세트가 바뀔 때만 이미지 갱신
            .onChange(of: Set(vm.bookmarks.map(\.coinSymbol)), initial: false) {
                Task { @MainActor in
                    await vm.loadCoinImages()
                }
            }
        }
        .confirmationDialog("내보내기", isPresented: $showingExportOptions, titleVisibility: .visible) {
            Button("이미지로 내보내기") {
                if let url = vm.makeFullReportPNGURL(scale: 2.0) {
                    sharingItems = [url]
                    isShowingShareSheet = true
                }
            }

            Button("PDF 내보내기") {
                if let url = vm.makeFullReportPDF(scale: 2.0) {
                    sharingItems = [url]
                    isShowingShareSheet = true
                }
            }

            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ActivityView(activityItems: sharingItems)
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
//                DefaultProgressView(message: "분석중...")
            } else if let briefing {
                BadgeLabelView(text: "📝 투자 브리핑 요약")
                Text(briefing.briefing)
                    .font(.system(size: 12))
                    .lineSpacing(6)

                Spacer(minLength: 0)

                BadgeLabelView(text: "✅ 전략 제안")
                Text(briefing.strategy)
                    .font(.system(size: 12))
                    .lineSpacing(6)
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

/// 내보내기 전용 뷰
struct ExportReportView: View {
    let dto: PortfolioBriefingDTO
    let coins: [BookmarkEntity]
    let imageURLProvider: (String) -> URL?

    @State private var selectedCategory: SortCategory? = .name
    @State private var nameOrder: SortOrder = .none
    @State private var priceOrder: SortOrder = .none
    @State private var volumeOrder: SortOrder = .none

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 브리핑
            BriefingSectionView(
                briefing: dto,
                isLoading: false,
                bookmarksEmpty: false,
                errorMessage: nil
            )

            HStack {
                SubheaderView(subheading: "북마크한 코인")
                Spacer()
            }
            .padding(.horizontal, 16)

            Divider().padding(.horizontal, 16)

            CoinListSectionView(
                sortedCoins: coins,
                selectedCategory: $selectedCategory,
                nameOrder: $nameOrder,
                priceOrder: $priceOrder,
                volumeOrder: $volumeOrder,
                imageURLProvider: { _ in nil },
                onDelete: { _ in }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
    }
}
