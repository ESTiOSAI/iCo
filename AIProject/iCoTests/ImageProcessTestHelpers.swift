//
//  ImageProcessTestHelpers.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/17/25.
//

import UIKit
@testable import iCo

// MARK: - Helper Methods
final class ImageProcessTestHelpers {    
    static func createTestImage(with text: String) -> CGImage? {
        let width = 300
        let height = 100
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // RGBA 8비트 구성으로 CGContext 생성
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        // 배경 흰색
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        // UIKit 없이 텍스트를 직접 Core Graphics로 그리려면 NSAttributedString을 활용해야 함
        let textRect = CGRect(x: 10, y: 40, width: 280, height: 50)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
        let path = CGMutablePath()
        path.addRect(textRect)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)
        CTFrameDraw(frame, context)
        
        // CGContext → CGImage 생성
        return context.makeImage()
    }
    
    static func createMockCoinDTO() -> CoinDTO {
        CoinDTO(
            coinID: "KRW-BTC",
            koreanName: "비트코인",
            englishName: "Bitcoin"
        )
    }
}
