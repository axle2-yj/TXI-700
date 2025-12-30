//
//  PercentInputRow.swift
//  TXI-700
//
//  Created by 서용준 on 1/7/26.
//

import SwiftUI

struct PercentInputRow: View {
    let title: String
    @Binding var text: String
    var onSave: (Int) -> Void
    
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text("\(title) : ")
            
            TextField("\(title) 입력", text: $text)
                .focused($isFocused)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .onChange(of: isFocused) { focused, _ in
                   if !focused {
                       commit()
                    }
                }
            Text("%")
        }.onKeyboardDismiss {
            commit()
            isFocused = false
        }
    }
    
    private func commit() {
            guard
                !text.isEmpty,
                let value = Int(text),
                (0...100).contains(value)
            else { return }

            onSave(value)
        }
}

