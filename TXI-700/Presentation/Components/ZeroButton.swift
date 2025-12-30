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
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        Button("ZERO") {
            bleManager.sendCommand(.btz, log: "ZeroButton")
        }.frame(maxWidth: .infinity) // 화면 절반 차지
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(tint)
    }
}

