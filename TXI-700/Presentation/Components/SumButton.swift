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
        
    var body: some View {
        var isSum = false
        if !isSum {
            Button("SUM") {
                isSum = true
                performEnterAction()
            }.frame(maxWidth: .infinity, maxHeight: 50)
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(.black)
            .onReceive(bleManager.$isSum) { newValue in
                if newValue {
                    isSum = false
                    preformIndicatorAction()
                } else {
                    isSum = true
                }
            }
        }
    }
    
    private func performEnterAction() {
        onSum()
        bleManager.sendSumCommand()
    }
    
    private func preformIndicatorAction() {
        onSum()
    }
}
