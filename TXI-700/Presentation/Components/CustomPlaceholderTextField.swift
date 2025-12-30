//
//  CustomPlaceholderTextField.swift
//  TXI-700
//
//  Created by 서용준 on 1/13/26.
//

import SwiftUI

struct CustomPlaceholderTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .allowsHitTesting(false)
            }
            
            TextField("", text: $text)
                .foregroundColor(.black)
                .padding(10)
        }
        .textFieldStyle(.plain)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .focused($isFocused)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(tint)
        .frame(maxWidth: .infinity)
        .tint(.black)
        
    }
}

struct CustomPlacholderNumberTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .allowsHitTesting(false)
            }
            
            TextField("", text: $text)
                .foregroundColor(.black)
                .padding(10)
        }
        .focused($isFocused)
        .keyboardType(.numberPad)
        .textFieldStyle(.plain)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(tint)
        .tint(.black)
    }
}
