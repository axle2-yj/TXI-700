//
//  SendButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI
import Foundation

struct SendButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    @ObservedObject var viewModel: DataViewModel

    var onSendRequest: () -> Void

    let sendDataByte: [UInt8] = [
//        83, 78, 48, 48, 48, 48
    ]
    
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
                ? .white
                : .black
            )
            .disabled(viewModel.selectedType == nil)
    }
}
