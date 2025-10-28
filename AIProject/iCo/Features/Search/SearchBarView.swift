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
    
    var body: some View {
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
                    .font(.ico14)
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
            
            Button {
                isFocused = false
                searchText = ""
            } label: {
                Text("취소")
                    .foregroundStyle(.iCoNegative)
                    .font(.ico13)
            }
            .opacity(showCancel ? 1 : 0)
            .frame(width: showCancel ? 40 : 0, alignment: .trailing)
        }
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
