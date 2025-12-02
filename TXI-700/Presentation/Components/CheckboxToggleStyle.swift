//
//  CheckboxToggleStyle.swift
//  TXI-700
//
//  Created by 서용준 on 12/2/25.
//
import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            // 체크박스 이미지
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            // 토글 라벨
            configuration.label
        }
    }
}
