//
//  ImageProcessTestHelpers.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/17/25.
//

import UIKit
@testable import AIProject

// MARK: - Helper Methods
final class ImageProcessTestHelpers {
    static func createTestImage(with text: String) -> UIImage {
        let size = CGSize(width: 300, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        text.draw(at: CGPoint(x: 10, y: 40), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    static func createMockCoinDTO() -> CoinDTO {
        CoinDTO(
            coinID: "KRW-BTC",
            koreanName: "비트코인",
            englishName: "Bitcoin"
        )
    }
}
