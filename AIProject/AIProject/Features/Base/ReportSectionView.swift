//
//  ReportSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import SwiftUI

struct ReportSectionData<Value>: Identifiable {
    let id: String
    let icon: String
    let title: String
    let state: FetchState<Value>
    var timestamp: Date? = nil
    let onCancel: () -> Void
    let onRetry: () -> Void
}

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

#Preview() {
    @Previewable @State var maxHeight: CGFloat = 0
    
    HStack {
        ReportSectionView(
            data: ReportSectionData<String>(
                id: "success",
                icon: "chart.line.uptrend.xyaxis",
                title: "시장 요약",
                state: .success("리플(XRP)이 시카고상품거래소(CME)에서 미결제약정 10억 달러를 기록하며 가격이 폭등하고, 바이낸스에 대규모 스테이블코인이 유입되면서 암호화폐 시장에 반전 조짐이 나타나고 있습니다."),
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
        .frame(height: maxHeight)
        
        ReportSectionView(
            data: ReportSectionData<String>(
                id: "success",
                icon: "chart.line.uptrend.xyaxis",
                title: "시장 요약",
                state: .success("리플(XRP)이 시카고상품거래소(CME)에서 미결제약정 10억 달러를 기록하며 가격이 폭등하고, 바이낸스에 대규모 스테이블코인이 유입되면서 암호화폐 시장에 반전 조짐이 나타나고 있습니다. 다만, 대형 고래들의 매각 활동으로 인해 시장이 갑작스러운 매도세로 돌아서면서 투자자들이 불안해하고 있으며, 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. 비트코인이 11만 달러 저지선을 이탈하며 공포가 확산되고 있습니다. "),
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
        .frame(height: maxHeight)
    }
    .padding(.horizontal, 16)
    .onPreferenceChange(HeightPreferenceKey.self) { value in
        maxHeight = value
    }
}
