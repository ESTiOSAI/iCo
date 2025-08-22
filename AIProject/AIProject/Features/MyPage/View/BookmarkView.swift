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

    @State private var showBulkInsertSheet = false
    @State private var isShowingShareSheet = false
    @State private var sharingItems: [Any] = []
    @State private var showingExportOptions = false
    @State private var showDeleteConfirm = false
    @State private var didCopy = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookmarkEntity.timestamp, ascending: false)],
            animation: .default
    )
    private var bookmarks: FetchedResults<BookmarkEntity>

    private var isExportDisabled: Bool {
           if bookmarks.isEmpty || vm.briefing == nil { return true }
        switch vm.status {
        case .success:
            return false
        default:
            return true
        }
    }

    // 정렬 데이터
    var sortedCoins: [BookmarkEntity] {
        switch selectedCategory{
        case .name:
            switch nameOrder {
            case .ascending:
                return Array(bookmarks).sorted { $0.coinKoreanName < $1.coinKoreanName }
            case .descending:
                return Array(bookmarks).sorted { $0.coinKoreanName > $1.coinKoreanName }
            case .none:
                return Array(bookmarks)
            }
        case .volume:
            return Array(bookmarks)

        case .none:
            return Array(bookmarks)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HeaderView(heading: "북마크 관리")

                if !bookmarks.isEmpty {
                    HStack {
                        SubheaderView(imageName: "sparkles", subheading: "아이코가 북마크를 분석했어요")
                            .padding(.leading, -16)

                        Spacer()

                        RoundedButton(title: didCopy ? "복사 완료" : "내용 복사", imageName: didCopy ? "checkmark" : "document.on.document") {
                            guard let dto = vm.briefing else { return }
                            let text =
                        	"""
                        [분석 결과]
                        \(dto.briefing)
                        
                        [전략 제안]
                        \(dto.strategy)
                        """

                            UIPasteboard.general.string = text
                            didCopy = true

                            Task {
                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                await MainActor.run { didCopy = false }
                            }
                        }
                        .disabled(isExportDisabled)
                        .opacity(isExportDisabled ? 0.2 : 1.0)
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)

                    Group {
                        switch vm.status {
                        case .loading:
                            VStack(alignment: .center) {
                                DefaultProgressView(status: .loading, message: "아이코가 분석중입니다...") {
                                    vm.cancelTask()
                                }
                            }
                        case .success:
                            if let briefing = vm.briefing {
                                BriefingSectionView(briefing: briefing)
                            }
                        case .failure(let networkError):
                            VStack(alignment: .center) {
                                DefaultProgressView(status: .failure, message: networkError.localizedDescription) {
                                    Task { await vm.loadBriefing(character: .longTerm) }
                                }
                            }
                        case .cancel(let networkError):
                            VStack(alignment: .center) {
                                DefaultProgressView(status: .cancel, message: networkError.localizedDescription) {
                                    Task { await vm.loadBriefing(character: .longTerm) }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.aiCoLabel)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.aiCoBackgroundAccent)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.accent, lineWidth: 0.5)
                            )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 16)

                    Text(String.aiGeneratedContentNotice)
                        .font(.system(size: 11))
                        .foregroundColor(.aiCoNeutral)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.leading, 16)
                } else {
                    SubheaderView(imageName: "face.smiling", subheading: "북마크를 등록해주세요!")
                }

                HStack {
                    SubheaderView(subheading: "북마크한 코인")
 
                    Spacer()

                    RoundedButton(title: "전체 삭제", imageName: "trash") {
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
                .padding(.top, 20)
                .padding(.trailing, 16)
                .padding(.bottom, 16)

                HStack(spacing: 16) {
                    RoundedRectangleFillButton(title: "가져오기", imageName: "square.and.arrow.down", isHighlighted: .constant(false)) {
						showBulkInsertSheet = true
                    }
                    RoundedRectangleFillButton(title: "내보내기", imageName: "square.and.arrow.up", isHighlighted: .constant(false)) {
                        guard !isExportDisabled else { return }
                        showingExportOptions = true
                    }
                    .disabled(isExportDisabled)
                    .opacity(isExportDisabled ? 0.2 : 1.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 16)
                .padding(.trailing, 16)

                if sortedCoins.isEmpty {
                    Text("북마크한 코인이 없습니다 🥵")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .multilineTextAlignment(.center)
                        .padding(16)
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
                    .padding(16)
                }
            }
            .task {
                guard !bookmarks.isEmpty else {
                    vm.briefing = nil
                    vm.imageMap = [:]
                    return
                }
                async let imagesTask: () = vm.loadCoinImages()
                async let briefingTask: () = vm.loadBriefing(character: .longTerm)
                _ = await (imagesTask, briefingTask)
            }
            // 북마크 심볼 세트가 바뀔 때만 이미지 갱신
            .onChange(of: Set(bookmarks.map(\.coinSymbol)), initial: false) { _,_  in
                Task { @MainActor in await vm.loadCoinImages() }
            }
            // 북마크 개수 변화 시 브리핑 갱신
            .onChange(of: bookmarks.count, initial: false) { _,_  in
                Task { @MainActor in await vm.loadBriefing(character: .longTerm) }
            }
        }
        .backgroundStyle(.aiCoBackground)
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
        .sheet(isPresented: $showBulkInsertSheet) {
            BookmarkBulkInsertView()
        }
    }
}

struct BriefingSectionView: View {
    let briefing: PortfolioBriefingDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("분석 결과")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(.aiCoAccent))

            briefing.briefing
                .byCharWrapping
                .highlightTextForNumbersOperator()
                .font(.system(size: 14))
                .fontWeight(.regular)
                .lineSpacing(6)

            Spacer(minLength: 20)

            Text("전략 제안")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(.aiCoAccent))

            briefing.strategy
                .byCharWrapping
                .highlightTextForNumbersOperator()
                .font(.system(size: 14))
                .fontWeight(.regular)
                .lineSpacing(6)
        }
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
            BriefingSectionView(briefing: dto)

            HStack {
                SubheaderView(subheading: "북마크한 코인")
                Spacer()
            }
            .padding(.horizontal, 16)

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
