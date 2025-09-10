//
//  UIImage+Util.swift
//  iCo
//
//  Created by Kitcat Seo on 9/10/25.
//

import SwiftUI

extension UIImage {
    func optimizeImages() -> (display: UIImage, ocr: CGImage)? {
        let maxDimension: CGFloat = 1024
        let currentMax = max(size.width, size.height)
        
        // 이미지가 기준 사이즈보다 크면 리사이징하기
        if currentMax > maxDimension {
            let aspectRatio = size.width / size.height
            var newSize: CGSize
            
            // 원본 이미지 비율에 맞게 사이즈 책정하기
            if aspectRatio > 1 {
                newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            }
            
            // 새로운 사이즈로 이미지 렌더링하기
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let displayImage = renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: newSize))
            }
            
            guard let ocrImage = displayImage.cgImage else { return nil }
            return (displayImage, ocrImage)
        } else {
            guard let ocrImage = self.cgImage else { return nil }
            return (self, ocrImage)
        }
    }
}
