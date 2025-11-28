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
        0x53, 0x53, 0x31, 0x30, 0x30, 0x30, 0x30, 0x30, 0x0D, 0x0A
    ]

    var body: some View {
        Button("ZERO") {
            print("ZERO Point Send Result: \(bleManager.sendData(zeroPointByte))")
        }
    }
}

