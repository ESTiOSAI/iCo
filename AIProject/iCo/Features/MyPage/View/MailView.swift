//
//  MailView.swift
//  AIProject
//
//  Created by 장지현 on 8/22/25.
//

import SwiftUI
import MessageUI

/// 앱 내에서 기본 메일 작성 화면을 표시하기 위한 SwiftUI 래퍼 뷰입니다.
///
/// `MFMailComposeViewController`를 사용하여 사용자가 피드백 메일을 보낼 수 있도록 합니다.
/// 기본 수신자, 제목, 본문이 설정되며, 작성 완료 시 자동으로 닫힙니다.
///
/// - Note:
///   `UIViewControllerRepresentable`을 구현하여 SwiftUI에서 UIKit의 메일 작성기를 사용할 수 있습니다.
struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    /// `MFMailComposeViewControllerDelegate`를 구현해 메일 작성 종료 시 뷰를 닫는 코디네이터 클래스입니다.
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["teamicohelp@gmail.com"])
        vc.setSubject("[아이코(AICo)] 피드백")
        vc.setMessageBody("아이코에 대한 다양한 내용을 작성해주세요.", isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
