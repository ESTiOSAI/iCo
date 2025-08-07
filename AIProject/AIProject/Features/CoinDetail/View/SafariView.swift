//
//  SafariView.swift
//  AIProject
//
//  Created by 장지현 on 8/5/25.
//

import SwiftUI
import SafariServices

/// SwiftUI에서 Safari 브라우저를 모달 형태로 띄우기 위한 래퍼 뷰입니다.
///
/// `SFSafariViewController`를 사용하여 주어진 URL을 사파리 뷰로 표시합니다.
///
/// - Parameters:
///   - url: 표시할 웹 페이지의 URL입니다.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
