//
//  NoEmailGuideView.swift
//  AIProject
//
//  Created by 장지현 on 8/27/25.
//


/// 메일 계정이 설정되지 않은 경우 사용자에게 안내하는 뷰입니다.
///
/// - Features:
///   - 상단에 닫기 버튼(`showClose == true`일 때만 표시)
///   - 메일 계정 추가를 안내하는 플레이스홀더 뷰
///   - 설정 앱으로 이동하여 계정을 추가할 수 있는 버튼
///
/// - Parameters:
///   - showClose: 상단 닫기 버튼 표시 여부 (기본값: `false`)
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
        .interactiveSwipeBackEnabled()
    }
}
