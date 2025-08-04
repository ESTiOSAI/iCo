//
//  ReportView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var viewModel: ReportViewModel
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 0) {
                ReportSectionView(title: "한눈에 보는 \(viewModel.koreanName)", contents: [viewModel.coinOverView])
                
                ReportSectionView(title: "오늘 시장 분위기 살펴보기", contents: [viewModel.coinTodayTrends])
                
                ReportSectionView(title: "주간 동향 확인", contents: [viewModel.coinWeeklyTrends])
                
                ReportNewsSectionView(title: "주요 뉴스", articles: viewModel.coinTodayTopNews, isNews: true)
            }
        }
        .padding(.top, 15)
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    return ReportView(viewModel: ReportViewModel(coin: sampleCoin))
}

struct ReportSectionView: View {
    let title: String
    var contents: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .padding(.bottom, 8)
                
                ForEach(contents, id: \.self) { content in
                    VStack(spacing: 0) {
                        Text(content)
                            .font(.system(size: 13))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.aiCoBorder)
                    }
                    .padding(.bottom, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct ReportNewsSectionView: View {
    let title: String
    var articles: [CoinArticle]
    var isNews: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .padding(.bottom, 8)
                
                ForEach(articles) { article in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Button {
                                // FIXME: 링크 연결
                            } label: {
                                Text("원문 보기 >")
                                    .font(.system(size: 12))
                                    .padding(10)
                            }
                            .foregroundStyle(.aiCoLabelSecondary)
                        }
                        
                        Text(article.title)
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(article.summary)
                            .font(.system(size: 13))
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}
