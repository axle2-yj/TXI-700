//
//  SendButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI
import Foundation

struct SendButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bleManager: BluetoothManager
    @ObservedObject var viewModel: DataViewModel
    
    var onSendRequest: () -> Void
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    private var oppositionTint: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        Button("SEND") {
            onSendRequest()
        }.frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.selectedType == nil
                ? Color.gray.opacity(0.4)
                : Color.gray.opacity(0.2)
            )
            .cornerRadius(6)
            .foregroundColor(
                viewModel.selectedType == nil
                ? oppositionTint
                : tint
            )
            .disabled(viewModel.selectedType == nil)
    }
}
