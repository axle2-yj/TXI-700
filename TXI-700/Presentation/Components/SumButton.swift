//
//  SumButton.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Foundation

struct SumButton: View {
    var onSum: () -> Void
    
    var body: some View {
        Button("SUM") {
            onSum()
        }.frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(6)
        .foregroundColor(.black)
    }
}
