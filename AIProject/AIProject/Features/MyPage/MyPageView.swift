//
//  MyPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MyPageView: View {
    @State private var showBulkInsertSheet = false
    
    var body: some View {
        VStack {
            Button("Open") {
                showBulkInsertSheet = true
            }
        }
        .sheet(isPresented: $showBulkInsertSheet) {
            BookmarkBulkInsertView()
        }
    }
}

#Preview {
    MyPageView()
}
