//
//  HeaderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 7/30/25.
//

import SwiftUI

/// 헤더에 표시할 제목을 필수로 전달해주세요.
/// 마켓이나 북마크 메뉴일 경우 각 파라메터에 true 값을 넣어주세요.
struct HeaderView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.dismiss) var dismiss
    
    let heading: String
    let coinSymbol: String?
    let headingColor: Color
    
    var showSearchButton = false
    var showBackButton = false
    
    let onSearchTap: () -> Void
    let onBackButtonTap: () -> Void

    init(heading: String, headingColor: Color = .aiCoLabel, coinSymbol: String? = nil, showSearchButton: Bool = false, onSearchTap: @escaping () -> Void = { }, showBackButton: Bool = false, onBackButtonTap: @escaping () -> Void = { }) {
        self.heading = heading
        self.headingColor = headingColor
        self.coinSymbol = coinSymbol
        self.showSearchButton = showSearchButton
        self.onSearchTap = onSearchTap
        self.showBackButton = showBackButton
        self.onBackButtonTap = onBackButtonTap
    }
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            if showBackButton {
                Button {
                    dismiss()
                    onBackButtonTap()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .fontWeight(.regular)
                        .tint(.aiCoLabelSecondary.opacity(0.6))
                }
                .padding(.trailing, .spacing)
            }
            
            HStack {
                HStack(alignment: .center, spacing: 8) {
                    if let coinSymbol {
                        CoinView(symbol: "\(coinSymbol)", size: 30)
                    }
                    
                    Text(heading)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(headingColor)
                        .multilineTextAlignment(showBackButton ? .center : .leading)
                    
                    if let coinSymbol {
                        Text(coinSymbol)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.aiCoLabelSecondary)
                    }
                }
                .frame(maxWidth: showBackButton ? .infinity : nil)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
}

#Preview {
    HeaderView(heading: "북마크 관리")
        .padding(.bottom, 16)
    HeaderView(heading: "북마크 관리", showBackButton: true)
        .padding(.bottom, 16)
    HeaderView(heading: "비트코인", coinSymbol: "BTC", showBackButton: true)
        .padding(.bottom, 16)
    SubheaderView(subheading: "북마크하신 코인들을 분석해봤어요")
}
