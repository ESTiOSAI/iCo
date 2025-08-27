//
//  NoEmailGuideView.swift
//  AIProject
//
//  Created by 장지현 on 8/27/25.
//

import SwiftUI

struct NoEmailGuideView: View {
    @Environment(\.dismiss) private var dismiss

    let showClose: Bool
    
    init(showClose: Bool = false) {
        self.showClose = showClose
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            if showClose {
                HStack {
                    Spacer()
                    
                    RoundedButton(imageName: "xmark") {
                        dismiss()
                    }
                }
            }

            CommonPlaceholderView(
                imageName: "placeholder-no-mail",
                text: "문의하기 기능 사용을 위해 메일 계정을 설정해주세요\n설정 → Mail 앱에서 계정 추가"
            )

            RoundedRectangleFillButton(
                title: "계정 추가",
                imageName: "gear",
                isHighlighted: .constant(true)
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .padding()
    }
}
