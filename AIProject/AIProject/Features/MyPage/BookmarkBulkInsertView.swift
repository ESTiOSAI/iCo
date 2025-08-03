//
//  BookmarkBulkInsertView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI
import PhotosUI

struct BookmarkBulkInsertView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = ImageProcessViewModel()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                SubheaderView(subheading: "보유 코인이나 관심 코인을 한번에 등록하시려면 스크린샷을 업로드하세요.")
                
                Text("아이코가 자동으로 북마크를 등록해드려요.")
                    .padding(.horizontal, 16)
            }
            
            VStack(spacing: 18) {
                Spacer()
                
                VStack {
                    if selectedImage != nil {
                        ImagePreviewView(selectedImage: selectedImage!)
                    } else {
                        Spacer()
                        
                        Text("이미지를 선택해주세요")
                            .foregroundStyle(.aiCoLabel.opacity(0.5))
                        
                        Spacer()
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
                        vm.performOCR(from: selectedImage!)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookmarkBulkInsertView()
    }
}
