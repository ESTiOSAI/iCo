//
//  ReportSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import SwiftUI

/// 보고서 화면에서 섹션별 데이터를 표현하기 위한 모델입니다.
///
/// - Properties:
///   - id: 섹션을 구분하기 위한 고유 식별자
///   - icon: 헤더에 표시할 SF Symbol 아이콘 이름
///   - title: 섹션 제목
///   - state: 섹션의 데이터 상태(`FetchState`)
///   - timestamp: 데이터의 마지막 업데이트 시각 (선택 사항)
///   - onCancel: 로딩 중 취소 동작을 실행하는 클로저
///   - onRetry: 실패나 취소 시 재시도를 실행하는 클로저
struct ReportSectionData<Value>: Identifiable {
    let id: String
    let icon: String
    let title: String
    let state: FetchState<Value>
    var timestamp: Date? = nil
    let onCancel: () -> Void
    let onRetry: () -> Void
}

/// 보고서 화면에서 섹션 단위로 콘텐츠를 표시하는 뷰입니다.
///
/// 아이콘, 제목, 상태에 따른 콘텐츠, 재시도/취소 버튼 등을 포함하여
/// 개별 섹션을 카드 형태로 표현합니다.
///
/// - Generics:
///   - Value: 섹션에 표시할 데이터 타입
///   - Trailing: 헤더 우측에 배치할 추가 뷰 타입
///   - Content: 본문에 표시할 뷰 타입
struct ReportSectionView<Value, Trailing: View, Content: View>: View {
    let data: ReportSectionData<Value>
    @ViewBuilder var trailing: (Value) -> Trailing
    @ViewBuilder var content: (Value) -> Content
    
    private let cornerRadius: CGFloat = 20
    
    // No-trailing initializer
    init(
        data: ReportSectionData<Value>,
        @ViewBuilder content: @escaping (Value) -> Content
    ) where Trailing == EmptyView {
        self.data = data
        self.trailing = { _ in EmptyView() }
        self.content = content
    }
    
    // Trailing initializer
    init(
        data: ReportSectionData<Value>,
        @ViewBuilder trailing: @escaping (Value) -> Trailing,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.data = data
        self.trailing = trailing
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: data.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.aiCoAccent)
                
                Text(data.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.aiCoLabel)
                
                Spacer()
                
                if case let .success(value) = data.state {
                    trailing(value)
                }
            }
            
            // Content
            Group {
                switch data.state {
                case .loading:
                    DefaultProgressView(status: .loading, message: "아이코가 리포트를 작성하고 있어요") {
                        data.onCancel()
                    }
                case .success(let value):
                    content(value)
                        .font(.system(size: 14))
                        .foregroundStyle(.aiCoLabel)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    if let ts = data.timestamp {
                        TimestampWithRefreshButtonView(timestamp: ts) {
                            data.onRetry()
                        }
                    }
                case .cancel(let error):
                    DefaultProgressView(status: .cancel, message: error.localizedDescription) {
                        data.onRetry()
                    }
                case .failure(let error):
                    DefaultProgressView(status: .failure, message: error.localizedDescription) {
                        data.onRetry()
                    }
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(.aiCoBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPreferenceKey.self,
                                value: geo.size.height)
            }
        )
    }
}

#Preview("둘 중 더 큰 높이로 적용") {
    @Previewable @Environment(\.horizontalSizeClass) var hSizeClass
    @Previewable @State var maxHeight: CGFloat = 0
    
    ScrollView {
        let content = Group {
            ReportSectionView(
                data: ReportSectionData<String>(
                    id: "success",
                    icon: "chart.line.uptrend.xyaxis",
                    title: "시장 요약",
                    state: .success("짧은 글"),
                    timestamp: Date(),
                    onCancel: {},
                    onRetry: {}
                ),
                trailing: { value in
                    Button(action: { UIPasteboard.general.string = value }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("내용 복사")
                },
                content: { value in
                    Text(value)
                }
            )
            .frame(height: max(maxHeight, 250))
            
            ReportSectionView(
                data: ReportSectionData<String>(
                    id: "success",
                    icon: "chart.line.uptrend.xyaxis",
                    title: "시장 요약",
                    state: .success("긴 글. 리플(XRP)이 시카고상품거래소(CME)에서 미결제약정 10억 달러를 기록하며 가격이 폭등하고, 바이낸스에 대규모 스테이블코인이 유입되면서 암호화폐 시장에 반전 조짐이 나타나고 있습니다. 다만, 대형 고래들의 매각 활동으로 인해 시장이 갑작스러운 매도세로 돌아서면서 투자자들이 불안해하고 있으며, 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. 리플(XRP)이 시카고상품거래소(CME)에서 미결제약정 10억 달러를 기록하며 가격이 폭등하고, 바이낸스에 대규모 스테이블코인이 유입되면서 암호화폐 시장에 반전 조짐이 나타나고 있습니다. 다만, 대형 고래들의 매각 활동으로 인해 시장이 갑작스러운 매도세로 돌아서면서 투자자들이 불안해하고 있으며, 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다."),
                    timestamp: Date(),
                    onCancel: {},
                    onRetry: {}
                ),
                trailing: { value in
                    Button(action: { UIPasteboard.general.string = value }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("내용 복사")
                },
                content: { value in
                    Text(value)
                }
            )
            .frame(height: max(maxHeight, 250))
        }
        
        if hSizeClass == .regular {
            HStack { content }
        } else {
            VStack { content }
        }
        
    }
    .padding(.horizontal, 16)
    .onPreferenceChange(HeightPreferenceKey.self) { value in
        maxHeight = value
    }
}

#Preview("최소 높이 적용") {
    @Previewable @Environment(\.horizontalSizeClass) var hSizeClass
    @Previewable @State var maxHeight: CGFloat = 0
    
    ScrollView {
        let content = ReportSectionView(
            data: ReportSectionData<String>(
                id: "success",
                icon: "chart.line.uptrend.xyaxis",
                title: "시장 요약",
                state: .success("짧은 글"),
                timestamp: Date(),
                onCancel: {},
                onRetry: {}
            ),
            trailing: { value in
                Button(action: { UIPasteboard.general.string = value }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("내용 복사")
            },
            content: { value in
                Text(value)
            }
        )
            .frame(height: max(maxHeight, 250))
        
        
        if hSizeClass == .regular {
            HStack {
                content
                content
            }
        } else {
            VStack {
                content
                content
            }
        }
        
    }
    .padding(.horizontal, 16)
    .onPreferenceChange(HeightPreferenceKey.self) { value in
        maxHeight = value
    }
}
