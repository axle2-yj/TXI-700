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
        HStack {
            // 왼쪽: 뒤로가기
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    //car_inmotion
                    //car_auto_inmotion
                    .font(.title2)
                    .padding()
            }
                        
            Image(viewModel.imageName)
                .resizable()
                .font(.body)
            
            Spacer()
            // 가운데: 타이틀
            Text(title)
                .font(.headline)
            
            Spacer()
            
            // 오른쪽: 설정 버튼
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .padding()
            }
        }
        .padding(.horizontal)
                .frame(height: 50)
                    .background(Color(.systemGray6))

    }
}
