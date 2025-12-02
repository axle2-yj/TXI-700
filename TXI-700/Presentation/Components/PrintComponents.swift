//
//  PrintComponents.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI

@ViewBuilder
func weightRow(_ title: String, _ v1: String, _ v2: String) -> some View {
    HStack {
        Text(title)
        Text(v1)
        Text(v2)
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .lineLimit(1)
}

@ViewBuilder
func simpleRow(_ title: String, _ value: String) -> some View {
    HStack {
        Text(title)
        Text(LocalizedStringKey(value))
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .lineLimit(1)
}


@ViewBuilder
func textFieldRow(binding: Binding<String>) -> some View {
    TextField("입력", text: binding)
        .textFieldStyle(.roundedBorder)
}

@ViewBuilder
func lineText(_ value: String) -> some View {
    Text(LocalizedStringKey(value))
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
}

@ViewBuilder
func UnderlineFieldRow(_ title: String, _ value: String, _ minLength: Int) -> some View {
    HStack {
        Text(title)
        
        ZStack(alignment: .leading) {
            // 밑줄 (길게 표시)
            Text(String(repeating: "_", count: max(minLength, value.count)))
                .foregroundColor(.gray.opacity(0.6))
            
            // 실제 값
            Text(value)
                .foregroundColor(.black)
                .frame(alignment: .trailing)
                .padding(.trailing, 5)
        }
        
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
        
}

@ViewBuilder
func SettingLineText(_ value: String) -> some View {
    Text(LocalizedStringKey(value))
        .font(.title2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
}

