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
    @State var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            
            VStack {
                if selectedImage == nil {
                    // 이미지 등록 전
                    ContentUnavailableView {
                        Image("placeholder-no-image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .padding(50)
                            .background(.aiCoBackground)
                            .clipShape(.circle)
                            .overlay {
                                Circle()
                                    .stroke(.default, lineWidth: 0.5)
                            }
                            .padding(.bottom, 16)
                        
                        Text("선택된 이미지가 없어요")
                            .font(.system(size: 14))
                            .foregroundStyle(.aiCoLabelSecondary)
                    }
                } else {
                    // 이미지 등록 후
                    ZStack {
                        ImagePreviewView(selectedImage: selectedImage!)
                        
                        if vm.isLoading {
                            VStack(spacing: 16) {
                                DefaultProgressView(status: .loading, message: "아이코가 이미지를 분석하고 있어요") {
                                    vm.cancelTask()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    RoundedRectangleFillButtonView(title: "이미지 선택하기", isHighlighted: .constant(true))
                }
                .padding()
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
    }
}

#Preview {
    BookmarkBulkInsertView()
}
