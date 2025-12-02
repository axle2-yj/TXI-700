//
//  ZeroButton.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Foundation

struct ZeroButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    
    let zeroPointByte: [UInt8] = [
//        0x53, 0x53, 0x31, 0x30, 0x30, 0x30, 0x30, 0x30, 0x0D, 0x0A
        0x42, 0x54, 0x5A
    ]

    var body: some View {
        Button("ZERO") {
            print("ZERO Point Send Result: \(bleManager.sendData(zeroPointByte))")
        }.frame(maxWidth: .infinity) // 화면 절반 차지
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(.black)
    }
}

