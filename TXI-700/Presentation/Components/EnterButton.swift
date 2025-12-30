//
//  EnterButton.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Foundation

struct EnterButton: View {
    @ObservedObject var viewModel: SettingViewModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bleManager: BluetoothManager
    @Binding var loadAxleStatus: [LoadAxleStatus]
    
    @State private var hasChanged: Bool = false
    @State private var lastTotal: Int = 0  // Enter 누른 시점의 합 저장
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var onEnter: () -> Void
    var onEnterMassege: () -> Void
    let EnterByte: [UInt8] = [
        0x42, 0x54, 0x45
    ]
    
    var body: some View {
        VStack {
            Button("ENTER") {
                if (bleManager.axles[1]?.leftWeight ?? 0) < 0 || (bleManager.axles[1]?.rightWeight ?? 0) < 0 {
                    onEnterMassege()
                    return
                }
                bleManager.sendCommand(.bte, log: "Enter")
                onEnter()
            }.frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
                .foregroundColor(tint)
                .disabled(viewModel.modeName == "Auto Inmotion" || !hasChanged)
                .opacity(viewModel.modeName == "Auto Inmotion" ? 0.4 :(hasChanged ? 1.0 : 0.4))
                .onChange(of: bleManager.axles[1]?.leftWeight) { _, _ in detectChange() }
                .onChange(of: bleManager.axles[1]?.rightWeight) { _, _ in detectChange() }
        }
//        .onReceive(bleManager.$isEnter) { newValue in
//            if newValue {
//                performEnterAction()
//                onEnter()
//            }
//        }
        .onChange(of: bleManager.indicatorState) { state, _ in
            if state == IndicatorState.enter {
                if !viewModel.isSum {
                    print("enter")
                    performEnterAction()
                    onEnter()
                } else {
                    print("cancel")
                    viewModel.isSum = false
                }
            }
            else if state == IndicatorState.sum {
                print("enter sum")
                viewModel.isSum = true
            }
            else { return }
        }
    }
    
    private func performEnterAction() {
        appendAxleData()
        hasChanged = false
        lastTotal = bleManager.axles[1]?.totalWeight ?? 0
    }
    
    private func appendAxleData() {
        let currentAxles = [
            bleManager.axles[1]?.leftWeight ?? 0,
            bleManager.axles[1]?.rightWeight ?? 0
        ]
        
        if var last = loadAxleStatus.last {
            for axle in currentAxles {
                if last.loadAxlesData.count < 20 {
                    last.loadAxlesData.append(axle)
                }
            }
            last.total = last.loadAxlesData.reduce(0, +)
            loadAxleStatus[loadAxleStatus.count - 1] = last
        } else {
            let newStatus = LoadAxleStatus(
                id: 1,
                loadAxlesData: currentAxles,
                total: currentAxles.reduce(0, +)
            )
            loadAxleStatus.append(newStatus)
        }
    }
    
    private func detectChange() {
        let currentTotal = bleManager.axles[1]?.totalWeight ?? 0
        let wasZero = lastTotal == 0
        let isZero = currentTotal == 0
        
        if wasZero && !isZero {
            hasChanged = true
        }
        
        if isZero {
            hasChanged = false
        }
        
        lastTotal = currentTotal
    }
}

