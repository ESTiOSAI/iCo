//
//  BookmarkView.swift
//  AIProject
//
//  Created by 백현진 on 8/1/25.
//

import SwiftUI

struct BookmarkView: View {
    @StateObject private var vm: BookmarkViewModel
    
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
    
    @State private var shareURL: IdentifiableURL?
    
    init(coinStore: CoinStore) {
        _vm = StateObject(wrappedValue: BookmarkViewModel(coinStore: coinStore))
    }
    
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
                // 북마크한 코인이 없을 시 브리핑 섹션 숨기기
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
                        .opacity(isExportDisabled ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    Group {
                        switch vm.status {
                        case .loading:
                            DefaultProgressView(status: .loading, message: "아이코가 분석중입니다") {
                                vm.cancelTask()
                            }
                        case .success:
                            if let briefing = vm.briefing {
                                BriefingSectionView(briefing: briefing)
                            }
                        case .failure(let networkError):
                            DefaultProgressView(status: .failure, message: networkError.localizedDescription) {
                                Task { await vm.loadBriefing(character: vm.userInvestmentType) }
                            }
                        case .cancel(let networkError):
                            DefaultProgressView(status: .cancel, message: networkError.localizedDescription) {
                                Task { await vm.loadBriefing(character: vm.userInvestmentType) }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.aiCoLabel)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.aiCoBackgroundAccent)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.accentGradient, lineWidth: 0.5))
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    
                    Text(String.aiGeneratedContentNotice)
                        .font(.system(size: 11))
                        .foregroundColor(.aiCoNeutral)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
                
                HStack {
                    SubheaderView(subheading: "북마크한 코인")
                    
                    Spacer()
                    
                    RoundedButton(title: "전체 삭제", imageName: "trash") {
                        showDeleteConfirm = true
                    }
                    .disabled(bookmarks.isEmpty)
                    .opacity(bookmarks.isEmpty ? 0.6 : 1.0)
                    .alert("전체 북마크 삭제", isPresented: $showDeleteConfirm) {
                        Button("삭제", role: .destructive) {
                            vm.cancelTask()
                            vm.deleteAllBookmarks()
                        }
                        Button("취소", role: .cancel) { }
                    } message: {
                        Text("모든 북마크를 삭제하시겠습니까?")
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                
                // 북마크한 코인이 없을 시 플레이스홀더 뷰 보여주기
                if sortedCoins.isEmpty {
                    CommonPlaceholderView(imageName: "placeholder-no-coin", text: "아직 북마크한 코인이 없어요\n북마크를 등록해 아이코의 AI리포트를 받아보세요")
                        .padding(.vertical, 50)
                }
                
                HStack(spacing: 16) {
                    RoundedRectangleFillButton(title: "가져오기", imageName: "square.and.arrow.down", isHighlighted: .constant(sortedCoins.isEmpty)) {
                        showBulkInsertSheet = true
                    }
                    
                    // 북마크한 코인이 없을 시 내보내기 버튼 숨기기
                    if !bookmarks.isEmpty {
                        RoundedRectangleFillButton(title: "내보내기", imageName: "square.and.arrow.up", isHighlighted: .constant(false)) {
                            guard !bookmarks.isEmpty else { return }
                            showingExportOptions = true
                            
                        }
                        .disabled(bookmarks.isEmpty)
                        .opacity(bookmarks.isEmpty ? 0.6 : 1.0)
                        .confirmationDialog("내보내기", isPresented: $showingExportOptions, titleVisibility: .visible) {
                            
                            ShareLink("이미지로 내보내기", item: ShareablePNGReport{
                                try await vm.makeFullReportPNGURL(scale: 2.0) ?? { throw URLError(.cannotCreateFile) }()
                            }, preview: SharePreview("이미지"))
                            //
                            ShareLink(
                                "PDF 내보내기",
                                item: ShareablePDFReport {
                                    try await vm.makeFullReportPDF(scale: 2.0) ?? { throw URLError(.cannotCreateFile) }()
                                }, preview: SharePreview("PDF"))
                            
                            Button("취소", role: .cancel) {}
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                if !sortedCoins.isEmpty {
                    CoinListSectionView(
                        sortedCoins: sortedCoins,
                        selectedCategory: $selectedCategory,
                        nameOrder: $nameOrder,
                        priceOrder: $priceOrder,
                        volumeOrder: $volumeOrder,
                        imageProvider: { vm.imageProvider(for: $0) },
                        onDelete: { vm.deleteBookmark($0) }
                    )
                    .padding(16)
                }
            }
            .padding(.bottom, 0)
            .onChange(of: bookmarks.map(\.coinID), initial: true) { _, newValue in
                vm.cancelTask()

                guard !newValue.isEmpty else {
                    vm.briefing = nil
                    vm.imageMap = [:]
                    return
                }

                vm.task = Task {
                    async let imagesTask: Void = vm.loadCoinImages()
                    async let briefingTask: Void = vm.loadBriefing(character: vm.userInvestmentType)
                    _ = await (imagesTask, briefingTask)
                }
            }
            .onChange(of: Set(bookmarks.map(\.coinSymbol)), initial: false) { _,_  in
                Task { @MainActor in await vm.loadCoinImages() }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showBulkInsertSheet) {
            BookmarkBulkInsertView()
        }
        .navigationBarBackButtonHidden()
        .interactiveSwipeBackEnabled()
        .scrollIndicators(.hidden)
    }
}

#Preview {
    BookmarkView(coinStore: CoinStore(coinService: DefaultCoinService(network: NetworkClient())))
}
