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
    
    var showNewBadge = false
    
    init(heading: String, headingColor: Color = .aiCoLabel, topPadding: CGFloat = 30, coinSymbol: String? = nil, showBackButton: Bool = false, onBackButtonTap: ( () -> Void)? = nil, showNewBadge: Bool = false) {
        self.heading = heading
        self.headingColor = headingColor
        self.topPadding = topPadding
        self.coinSymbol = coinSymbol
        self.showBackButton = showBackButton
        self.onBackButtonTap = onBackButtonTap
        self.showNewBadge = showNewBadge
    }
    
    private let buttonWidth: CGFloat = 31 // 버튼 width 15 + 간격 16
    
    var body: some View {
        ZStack(alignment: .leading) {
            if showBackButton {
                BackButton(action: callBackAction)
                    .padding(.trailing, .spacing)
            }
            
            HStack {
                Spacer()
                    .frame(width: showBackButton ? buttonWidth : 0)
                
                content
                
                Spacer(minLength: showBackButton ? buttonWidth : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding)
        .padding(.bottom, 20)
    }
    
    /// 헤더의 콘텐츠 영역을 구성하는 뷰입니다.
    ///
    /// - 설명:
    ///   - `coinSymbol`이 존재하면 `CoinView`와 제목, 코인 심볼을 가로로 배치합니다.
    ///   - 제목은 길이에 따라 폰트 크기를 조정하고 최대 2줄까지 허용합니다.
    ///   - `showNewBadge`가 true이면 제목 우측에 'N' 배지를 표시합니다.
    ///   - `showBackButton`이 true일 때는 제목 정렬을 가운데로 설정합니다.
    @ViewBuilder
    private var content: some View {
        if let coin = coinSymbol {
            HStack(alignment: .center, spacing: 8) {
                CoinView(symbol: "\(coin)", size: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 4) {
                        Text(heading)
                            .font(.system(size: heading.count < 11 ? 21 : 18, weight: .black))
                            .foregroundStyle(.aiCoLabel)
                            .lineLimit(2)
                        
                        if showNewBadge {
                            Text("N")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Circle().foregroundStyle(.aiCoAccent))
                        }
                    }
                    
                    Text(coin)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.aiCoLabelSecondary)
                }
            }
        } else {
            HStack(alignment: .center, spacing: 8) {
                Text(heading)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(headingColor)
                    .lineLimit(2)
                    .multilineTextAlignment(showBackButton ? .center : .leading)
            }
            .frame(maxWidth: showBackButton ? .infinity : nil)
        }
    }
    
    /// 뒤로가기 버튼 동작을 처리하는 메서드입니다.
    ///
    /// - 동작:
    ///   - `onBackButtonTap` 클로저가 설정되어 있으면 해당 클로저를 실행합니다.
    ///   - 설정되어 있지 않으면 기본 동작으로 현재 화면을 dismiss 합니다.
    private func callBackAction() {
        if let onBackButtonTap {
            onBackButtonTap()
        } else {
            dismiss()
        }
    }
}

/// 헤더 좌측에 표시되는 뒤로가기 버튼 뷰입니다.
///
/// - Properties:
///   - action: 버튼 탭 시 실행할 클로저
private struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 24)
                .fontWeight(.regular)
                .tint(.aiCoLabelSecondary.opacity(0.6))
        }
    }
}

#Preview {
    // 왼쪽 정렬
    HeaderView(heading: "북마크 관리")
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: false)
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: true, showNewBadge: true)
        .padding(.bottom, 16)
    HeaderView(heading: "월드리버티파이낸셜유에스디월드리버티파이낸셜유에스디", coinSymbol: "BTC", showBackButton: true)
        .padding(.bottom, 16)
    
    // 가운데 정렬
    HeaderView(heading: "북마크 관리", showBackButton: true)
        .padding(.bottom, 16)
}
