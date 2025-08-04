//
//  ImagePreviewView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

/// 사용자가 등록한 이미지를 표시하는 뷰
struct ImagePreviewView: View {
    var selectedImage: UIImage
    
    var body: some View {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
    }
}
