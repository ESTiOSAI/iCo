//
//  ImagePreviewView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/1/25.
//

import SwiftUI

struct ImagePreviewView: View {
    var selectedImage: UIImage
    
    var body: some View {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
    }
}
