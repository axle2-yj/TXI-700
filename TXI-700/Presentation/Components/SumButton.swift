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
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
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
                .foregroundColor(tint)
                .onChange(of: bleManager.indicatorState) { state, _ in
                    switch state {
                    case IndicatorState.sum:
                        if !isSum {
                            isSum = true
                            preformIndicatorAction()
                        } else {
                            isSum = false
                        }
                    default:
                        break
                    }
                }
//                .onReceive(bleManager.$isSum) { newValue in
//                    if newValue {
//                        isSum = false
//                        preformIndicatorAction()
//                    } else {
//                        isSum = true
//                    }
//                }
        }
    }
    
    private func performEnterAction() {
        onSum()
        bleManager.sendCommand(.bts, log: "Sum Send Result")
    }
    
    private func preformIndicatorAction() {
        onSum()
    }
}
