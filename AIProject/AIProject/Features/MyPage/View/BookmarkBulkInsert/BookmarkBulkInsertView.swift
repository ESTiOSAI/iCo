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
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("보유 코인이나 관심 코인을 한번에 등록하시려면 스크린샷을 업로드하세요.")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("아이코가 자동으로 북마크를 등록해드려요.")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 18) {
                Spacer()
                
                VStack {
                    if selectedImage == nil {
                        // 이미지 등록 전
                        Spacer()
                        
                        Text("이미지를 선택해주세요")
                            .foregroundStyle(.aiCoLabel.opacity(0.5))
                        
                        Spacer()
                    } else {
                        // 이미지 등록 후
                        ZStack {
                            ImagePreviewView(selectedImage: selectedImage!)
                                .opacity(vm.isLoading ? 0.2 : 1)
                                .blur(radius: vm.isLoading ? 1 : 0)
                            
                            if vm.isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(2)
                                    
                                    Text("이미지 분석중...")
                                        .font(.footnote)
                                        .foregroundStyle(.aiCoLabel)
                                    
                                    //TODO: 분석 작업 취소 기능 구현하기
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(.aiCoBackground)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("이미지 선택하기")
                            .foregroundStyle(.aiCoBackground)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                    .background(.aiCoAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            }
            .navigationTitle("북마크 가져오기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.aiCoLabelSecondary)
                    }
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        vm.processImage(from: selectedImage!)
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
                Text("사진에서 \(formattedCoinIDs) 코인을 발견했어요.")
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
        .onAppear {
            do {
                print(try BookmarkManager.shared.fetchAll().count)
            } catch {
                print("🚨 CoreData 에러", error)
            }
        }
    }
}

extension BookmarkBulkInsertView {
    private func clearCoinIDArray() {
        vm.verifiedCoinIDs = []
    }
}

#Preview {
    NavigationStack {
        BookmarkBulkInsertView()
    }
}
