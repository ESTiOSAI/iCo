//
//  ReportView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct ReportView: View {
    let coin: Coin
    private let sampleDescriptor: String = "비트코인은 2009년 사토시 나카모토님이 제안하신 최초의 분산형 디지털 암호화폐예요. \n총 발행량이 2,100만 개로 제한되어 있어 희소성이 큰 특징이에요. \n블록체인 기술을 기반으로 한 분산원장 구조를 사용해요. \n작업증명(PoW) 알고리즘으로 네트워크 보안을 유지해요."
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 0) {
                ReportSectionView(title: "한눈에 보는 \(coin.koreanName)", contents: [sampleDescriptor])
                
                ReportSectionView(title: "오늘 시장 분위기 살펴보기", contents: [sampleDescriptor])
                
                ReportSectionView(title: "주간 동향 확인", contents: [sampleDescriptor])
                
                ReportSectionView(title: "주요 이슈 요약", contents: [sampleDescriptor, sampleDescriptor], isNews: true)
            }
        }
        .padding(.top, 15)
    }
}

#Preview {
    ReportView(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"))
}

struct ReportSectionView: View {
    let title: String
    let contents: [String]
    var isNews: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .padding(.bottom, 8)
                
                ForEach(contents, id: \.self) { content in
                    VStack(spacing: 0) {
                        if isNews {
                            HStack {
                                Spacer()
                                
                                Button {
                                    
                                } label: {
                                    Text("원문 보기 >")
                                        .font(.system(size: 12))
                                        .padding(10)
                                }
                                .foregroundStyle(.aiCoLabelSecondary)
                            }
                            .padding(.trailing)
                        }
                        
                        Text(content)
                            .font(.system(size: 13))
                            .padding(isNews ? 0 : 16)
                            .padding(.bottom, isNews ? 16 : 0)
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
