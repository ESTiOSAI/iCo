//
//  ContentSection.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/11/25.
//

import SwiftUI
import PhotosUI

struct ContentSection: View {
    @ObservedObject var vm: ImageProcessViewModel
    
    @State var selectedItem: PhotosPickerItem?
    @State var displayImage: UIImage?
    
    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            
            VStack {
                if displayImage == nil {
                    // 이미지 등록 전
                    CommonPlaceholderView(imageName: "placeholder-no-image", text: "선택된 이미지가 없어요")
                } else {
                    // 이미지 등록 후
                    ZStack {
                        if let displayImage {
                            ImagePreviewView(selectedImage: displayImage)
                        }
                        
                        if vm.isLoading {
                            VStack(spacing: 16) {
                                DefaultProgressView(status: .loading, message: "아이코가 이미지를 분석하고 있어요") {
                                    vm.cancelTask()
                                }
                                .background(.aiCoBackgroundWhite)
                            }
                        }
                    }
                    .animation(.easeIn(duration: 0.3), value: vm.isLoading)
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 10) {
                Text("ⓘ 코인 이름을 제외한 모든 정보는 기기 내에서 안전하게 처리됩니다")
                    .font(.footnote)
                    .foregroundStyle(.aiCoAccent)
                    .multilineTextAlignment(.center)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        RoundedRectangleFillButtonView(title: "이미지 선택하기", isHighlighted: .constant(true))
                    }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let photoPickerItem = newValue,
                       let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                       let originalImage = UIImage(data: data),
                       let optimizedImage = originalImage.resizeImageIfNeeded() {
                        // 미리보기 표시용 리사이즈 이미지
                        displayImage = optimizedImage
                        
                        // OCR 작업 용 최적화 이미지
                        guard let ocrImage = optimizedImage.cgImage else { return }
                        vm.processImage(from: ocrImage)
                    }
                }
            }
        }
    }
}

#Preview {
    BookmarkBulkInsertView()
}
