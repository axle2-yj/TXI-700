//
//  CustomTopBara.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct CustomListTopBar: View {
    @State private var isAddMode = true
    var title: String
    var onBack: () -> Void
    var onChange: () -> Void
    
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
                        Button(action: onChange) {
                            Image(systemName: isAddMode ? "plus" : "xmark")
                                            .font(.title)
                                            .foregroundColor(isAddMode ? .blue : .red)
                                            .padding()
                                            .background(.gray.opacity(0.2))
                                            .clipShape(Circle())
                                            .animation(.spring(), value: isAddMode)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color(.systemGray6))

    }
}
