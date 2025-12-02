//
//  CustomTopBara.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct CustomMainTopBar: View {
    var title: String
    var onBack: () -> Void
    var onSettings: () -> Void
    
    @ObservedObject var viewModel: SettingViewModel

    var body: some View {
        ZStack {
            // 가운데: 타이틀
            Text(title)
                .font(.headline)
                .lineLimit(1)

            HStack {
                // 왼쪽: 뒤로가기
                HStack(spacing: 8) {
                    Button(action: onBack) {
                        Image("return")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                    Image(viewModel.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .offset(x: -15)
                }
                
                Spacer()
                
                // 오른쪽: 설정 버튼
                Button(action: onSettings) {
                    Image("set")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }.padding(.horizontal)
            
        }.frame(height: 50)
         .background(Color(.systemGray6))
    }
}
