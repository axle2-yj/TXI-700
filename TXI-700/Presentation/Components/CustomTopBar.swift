//
//  CustomTopBar.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import SwiftUI

struct CustomTopBar: View {
    var title: String
    var onBack: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var returnImage: String {
        colorScheme == .dark ? "return_dark" : "return"
    }
    
    var body: some View {
        ZStack {
            // 가운데 타이틀
            Text(title)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                // 왼쪽: 뒤로가기 버튼
                Button(action: onBack) {
                    Image(returnImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                Spacer()
            }.padding(.horizontal)
        }
        .frame(height: 50)
        .background(Color(.systemGray6))
    }
}
