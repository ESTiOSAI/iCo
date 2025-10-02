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
    var topPadding: CGFloat
    
    var showBackButton = false
    var onBackButtonTap: (() -> Void)?

    init(heading: String, headingColor: Color = .aiCoLabel, topPadding: CGFloat = 30, coinSymbol: String? = nil, showBackButton: Bool = false, onBackButtonTap: ( () -> Void)? = nil) {
        self.heading = heading
        self.headingColor = headingColor
        self.topPadding = topPadding
        self.coinSymbol = coinSymbol
        self.showBackButton = showBackButton
        self.onBackButtonTap = onBackButtonTap
    }
    
    var body: some View {
        let buttonWidth: CGFloat = 44
        
        ZStack(alignment: .leading) {
            if showBackButton {
                Button {
                    if let onBackButtonTap {
                        onBackButtonTap()
                    } else {
                        dismiss()
                    }
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
                Spacer()
                    .frame(width: showBackButton ? buttonWidth : 0)
                
                HStack(alignment: .center, spacing: 8) {
                    if let coinSymbol {
                        CoinView(symbol: "\(coinSymbol)", size: 30)
                    }
                    
                    Text(heading)
                        .font(.system(size: heading.count < 11 ? 24 : 20, weight: .black))
                        .foregroundStyle(headingColor)
                        .lineLimit(2)
                        .multilineTextAlignment(showBackButton ? .center : .leading)
                    
                    if let coinSymbol {
                        Text(coinSymbol)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.aiCoLabelSecondary)
                    }
                }
                .frame(maxWidth: showBackButton ? .infinity : nil)
                
                Spacer(minLength: showBackButton ? buttonWidth : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding)
        .padding(.bottom, 20)
    }
}

#Preview {
    HeaderView(heading: "북마크 관리")
        .padding(.bottom, 16)
    HeaderView(heading: "북마크 관리", showBackButton: true)
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: true)
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: true)
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: false)
        .padding(.bottom, 16)
}
