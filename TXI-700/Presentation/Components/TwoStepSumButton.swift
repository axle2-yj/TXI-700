//
//  TwoStepSumButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/17/25.
//

import SwiftUI
import Foundation

struct TwoStepSumButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    var onSum: () -> Void
    
    var body: some View {
        Button("SUM") {
            performEnterAction()
        }.frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(6)
        .foregroundColor(.black)
        .onReceive(bleManager.$isSum) { newValue in
            print(newValue)
            if newValue {
                preformIndicatorAction()
            }
        }
    }
    private func performEnterAction() {
        onSum()
        send()
    }
    
    private func preformIndicatorAction() {
        onSum()
    }
    
    private func send() {
        bleManager.sendSumCommand()
    }
}
