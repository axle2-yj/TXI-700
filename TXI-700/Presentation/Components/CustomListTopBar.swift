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
    var onChange: (Bool) -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .padding()
            }

            Spacer()

            Text(title)
                .font(.headline)

            Spacer()

            Button(action: {
                isAddMode.toggle()
                onChange(isAddMode)
            }) {
                Image(systemName: isAddMode ? "plus" : "xmark")
                    .font(.title)
                    .foregroundColor(isAddMode ? .blue : .red)
                    .padding()
                    .animation(.spring(), value: isAddMode)
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color(.systemGray6))
    }
}
