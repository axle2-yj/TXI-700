//
//  CustomTopBara.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct CustomTopBar: View {
    var title: String
    var onBack: () -> Void
    var onSettings: () -> Void
    
    var body: some View {
        HStack {
            // 왼쪽: 뒤로가기
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                        }

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
