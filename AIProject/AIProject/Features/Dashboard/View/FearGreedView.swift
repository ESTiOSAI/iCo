//
//  FearGreedView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

struct FearGreedView: View {
    @StateObject var viewModel: FearGreedViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: FearGreedViewModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color.aiCoBackground, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                Circle()
                    .trim(from: 0.0, to: 0.75 * viewModel.indexValue / 100)
                    .stroke(.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                VStack(spacing: size.height * 0.15) {
                    Text("\(Int(viewModel.indexValue))")
                        .font(.system(size: size.width * 0.3, weight: .bold))
                        .foregroundColor(.aiCoLabel)
                    
                    Text(viewModel.classification)
                        .font(.system(size: size.width * 0.15, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.top, size.height * 0.01)
                }
                .offset(y: size.height * 0.15)
            }
        }
        .frame(width: 120, height: 120)
    }
}

#Preview {
    FearGreedView()
}
