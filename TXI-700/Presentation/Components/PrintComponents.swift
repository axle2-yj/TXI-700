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
        Text(title).foregroundColor(.black)
        Text(v1).foregroundColor(.black)
        Text(v2).foregroundColor(.black)
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .lineLimit(1)
}

@ViewBuilder
func simpleRow(_ title: String, _ value: String) -> some View {
    HStack {
        Text(title).foregroundColor(.black)
        Text(LocalizedStringKey(value))
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .lineLimit(1)
}


@ViewBuilder
func textFieldRow(binding: Binding<String>) -> some View {
    @EnvironmentObject var languageManager: LanguageManager
    
    CustomPlaceholderTextField(
        placeholder: "Input",
        text: binding)
}

@ViewBuilder
func lineText(_ value: String) -> some View {
    Text(LocalizedStringKey(value))
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.black)
        .lineLimit(1)
}

@ViewBuilder
func lineTextTailing(_ value: String) -> some View {
    Text(LocalizedStringKey(value))
        .frame(maxWidth: .infinity, alignment: .trailing)
        .foregroundColor(.black)
        .padding(2)
        .lineLimit(1)
}

@ViewBuilder
func UnderlineFieldRow(_ title: String, _ value: String, _ minLength: Int) -> some View {
    HStack {
        Text(title)
        
        Spacer()
        
        ZStack(alignment: .leading) {
            if value.isEmpty {
                // 밑줄 (길게 표시)
                Text(String(repeating: "_", count: max(minLength, value.count)))
                    .foregroundColor(.gray.opacity(0.6))
            } else {
                // 실제 값
                Text(value)
                    .foregroundColor(.black)
            }
        }.padding(.trailing, 5)
    }
    .frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
}

@ViewBuilder
func SettingLineText(_ value: String) -> some View {
    Text(LocalizedStringKey(value))
        .font(.title2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.black)
        .lineLimit(1)
}

