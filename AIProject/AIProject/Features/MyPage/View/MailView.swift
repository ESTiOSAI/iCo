//
//  MailView.swift
//  AIProject
//
//  Created by 장지현 on 8/22/25.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
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
        vc.setToRecipients(["jihyeon9975@icloud.com"])
        vc.setSubject("[아이코(AICo)] 피드백")
        vc.setMessageBody("아이코에 대한 다양한 내용을 작성해주세요.", isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
