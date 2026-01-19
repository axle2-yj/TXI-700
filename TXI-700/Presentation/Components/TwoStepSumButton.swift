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
    @Environment(\.colorScheme) var colorScheme
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    var onSum: () -> Void
    
    var body: some View {
        var isSum = false
        Button {
            performEnterAction()
        } label: {
            Text("SUM")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                .foregroundColor(tint)
                .contentShape(Rectangle())
    //            .onReceive(bleManager.$isSum) { newValue in
    //                print(newValue)
    //                if newValue {
    //                    preformIndicatorAction()
    //                }
    //            }
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
        bleManager.sendCommand(.bts, log: "Sum Send Result")
    }
}
