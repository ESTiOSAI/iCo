//
//  ReportView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//


/// 코인에 대한 AI 분석 리포트를 보여주는 뷰입니다.
///
/// `ReportViewModel`을 통해 받아온 개요, 주간 동향, 오늘의 시장 분위기, 주요 뉴스를 섹션별로 표시합니다.
///
/// - Parameters:
///   - coin: 리포트를 보여줄 대상 코인
import SwiftUI

struct ReportView: View {
    @StateObject var viewModel: ReportViewModel
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 0) {
                ReportSectionView(title: "한눈에 보는 \(viewModel.koreanName)", contents: [viewModel.coinOverView])
                // TODO: 웹사이트 정보를 지우거나, 웹사이트로 이동할 수 있는 버튼 만들기
                
                ReportSectionView(title: "주간 동향 확인", contents: [viewModel.coinWeeklyTrends])
                
                ReportSectionView(title: "오늘 시장 분위기 살펴보기", contents: [viewModel.coinTodayTrends])
                
                ReportNewsSectionView(title: "주요 뉴스", articles: viewModel.coinTodayTopNews, isNews: true)
            }
        }
        .padding(.top, 15)
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    return ReportView(coin: sampleCoin)
}

struct ReportSectionView: View {
    let title: String
    var contents: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                SubheaderView(subheading: title)
                    .padding(.bottom, 8)
                
                ForEach(contents, id: \.self) { content in
                    VStack(spacing: 0) {
                        Text(content)
                            .font(.system(size: 13))
                            .foregroundStyle(.aiCoLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.aiCoBorder)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 20)
    }
}

struct ReportNewsSectionView: View {
    @State private var safariItem: IdentifiableURL?
    
    let title: String
    var articles: [CoinArticle]
    var isNews: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                SubheaderView(subheading: title)
                    .padding(.bottom, 8)
                
                ForEach(articles) { article in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Button {
                                // FIXME: 앨런이 뉴스 원문 기사를 제대로 제공하지 않음
                                //                                if let url = URL(string: article.url) {
                                safariItem = IdentifiableURL(url: URL(string: "https://www.blockmedia.co.kr/archives/956560")!)
                                //                                }
                            } label: {
                                Text("원문 보기 >")
                                    .font(.system(size: 12))
                                    .padding(10)
                            }
                            .foregroundStyle(.aiCoLabelSecondary)
                        }
                        
                        Text(article.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.aiCoLabel)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(article.summary)
                            .font(.system(size: 13))
                            .foregroundStyle(.aiCoLabel)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.aiCoBorder)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 20)
        .sheet(item: $safariItem) { item in
            SafariView(url: item.url)
        }
    }
}
