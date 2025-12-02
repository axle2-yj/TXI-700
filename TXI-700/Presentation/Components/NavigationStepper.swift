//
//  NavigationStepper.swift
//  TXI-700
//
//  Created by 서용준 on 12/8/25.
//

import SwiftUI

struct NavigationStepper: View {
    @Binding var currentIndex: Int
    let totalCount: Int
    let onIndexChanged: (Int) -> Void

    private let buttonSize: CGFloat = 36

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            // 현재 위치 표시
            Text("\(currentIndex + 1) / \(totalCount)")
                .font(.body)

            Spacer()

            // ← 이전 버튼
            Button(action: {
                if currentIndex > 0 {
                    let newIndex = currentIndex - 1
                    currentIndex = newIndex

                    DispatchQueue.main.async {
                        onIndexChanged(newIndex)
                    }
                }
            }) {
                Image("return")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(currentIndex == 0 ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(currentIndex == 0 ? .white : .black)
            .cornerRadius(6)
            .disabled(currentIndex == 0)

            // → 다음 버튼
            Button(action: {
                if currentIndex < totalCount - 1 {
                    let newIndex = currentIndex + 1
                    currentIndex = newIndex

                    DispatchQueue.main.async {
                        onIndexChanged(newIndex)
                    }
                }
            }) {
                Image("return")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .rotationEffect(.degrees(180))
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(currentIndex == totalCount - 1 ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(currentIndex == totalCount - 1 ? .white : .black)
            .cornerRadius(6)
            .disabled(currentIndex == totalCount - 1)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)    // 전체 고정
    }
}
