//
//  SearchBarView.swift
//  AIProject
//
//  Created by 강대훈 on 8/11/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    @State private var showCancel: Bool = false
    @State private var containerHeight: CGFloat = 50
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private func recomputeHeight() {
        // Use a Dynamic Type–aware font close to .ico14 (subheadline ~ 15pt)
        let lineHeight = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        // Vertical paddings used below are 14(top)+14(bottom) = 28
        let calculated = lineHeight + 28
        // Ensure minimum tap target
        containerHeight = max(44, calculated)
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.iCoLabel)
                    
                    TextField("코인 이름으로 검색하세요", text: $searchText)
                        .keyboardType(.webSearch)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(.horizontal, 8)
                        .submitLabel(.search)
                        .font(.ico16)
                        .focused($isFocused)
                        .onChange(of: isFocused) {
                            showCancel = isFocused
                        }
                    
                    if !searchText.isEmpty {
                        CircleDeleteButton(fontSize: 9) {
                            print("Tapped")
                            searchText = ""
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(showCancel ? .iCoBackgroundBlue : .iCoBackground)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(showCancel ? .accentGradient : .defaultGradient, lineWidth: 0.5)
                }
                .animation(.bouncy, value: showCancel)
                
                Button {
                    isFocused = false
                    searchText = ""
                } label: {
                    Text("취소")
                        .foregroundStyle(.iCoNegative)
                        .font(.ico15)
                }
                .opacity(showCancel ? 1 : 0)
                .frame(width: showCancel ? 40 : 0, alignment: .trailing)
                .animation(.default, value: showCancel)
            }
        }
        .frame(height: containerHeight)
        .onAppear { recomputeHeight() }
        .onChange(of: dynamicTypeSize, { oldValue, newValue in
            recomputeHeight()
        })
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var searchText: String = "key"
    SearchBarView(searchText: $searchText)
        .padding()
        .frame(width:.infinity, height: 100)
}
