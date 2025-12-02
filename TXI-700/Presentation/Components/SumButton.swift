//
//  SumButton.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Foundation

struct SumButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    var onSum: () -> Void
    
    let sumByte: [UInt8] = [
        0x42, 0x54, 0x53
    ]
    
    var body: some View {
        Button("SUM") {
            performEnterAction()
        }.frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(6)
        .foregroundColor(.black)
        .onChange(of: bleManager.isSum) { _, _ in performEnterAction() }

    }
    
    private func performEnterAction() {
        onSum()
        print("Sum Send Result: \(bleManager.sendData(sumByte))")

    }
}
