//
//  BookmarkBulkInsertView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI
import PhotosUI

/// 이미지 등록을 통해 북마크 가져오기 기능을 실행하는 뷰
struct BookmarkBulkInsertView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = ImageProcessViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderSection()
                ContentSection()
                    .environmentObject(vm)
            }
            .navigationTitle("북마크 가져오기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    RoundedButton(imageName: "xmark") {
                        dismiss()
                    }
                }
            }
            .alert("북마크 분석 결과", isPresented: $vm.showAnalysisResultAlert) {
                Button {
                    vm.addToBookmark()
                    clearCoinIDArray()
                } label: {
                    Text("가져오기")
                }
                
                Button(role: .cancel) {
                    vm.showAnalysisResultAlert = false
                    clearCoinIDArray()
                } label: {
                    Text("취소")
                }
            } message: {
                let formattedCoinIDs = vm.verifiedCoinIDs.joined(separator: ", ")
                Text("이미지에서 \(formattedCoinIDs) 코인을 발견했어요.")
            }
            .alert("북마크 분석 실패", isPresented: $vm.showErrorMessage) {
                Button(role: .cancel) {
                    vm.showErrorMessage = false
                } label: {
                    Text("확인")
                }
            } message: {
                Text(vm.errorMessage)
            }
        }
        .task {
            do {
                guard vm.coinList == nil else { return }
                vm.coinList = try await vm.fetchCoinList()
                print(vm.coinList?.count)
            } catch {
                print(error)
            }
        }
    }
}

extension BookmarkBulkInsertView {
    func clearCoinIDArray() {
        vm.verifiedCoinIDs = []
    }
}

#Preview {
    NavigationStack {
        BookmarkBulkInsertView()
    }
}
