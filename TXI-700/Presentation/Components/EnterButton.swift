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
    @EnvironmentObject var bleManager: BluetoothManager
    @Binding var loadAxleStatus: [LoadAxleStatus]
    
    @State private var hasChanged: Bool = false
    @State private var lastTotal: Int = 0  // Enter 누른 시점의 합 저장
    @State private var everExceeded100: Bool = false  // ← 한 번이라도 100kg 이상 차이 발생

    let EnterByte: [UInt8] = [
        0x42, 0x54, 0x45 //, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x0A
    ]
    
    var body: some View {
        VStack {
            Button("ENTER") {
                print("Enter Send Result: \(bleManager.sendData(EnterByte))")
            }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(.black)
            .disabled(viewModel.modeName == "Auto Inmotion" || !hasChanged)
            .opacity(viewModel.modeName == "Auto Inmotion" ? 0.4 :(hasChanged ? 1.0 : 0.4))
            .onChange(of: bleManager.leftLoadAxel1) { _, _ in detectChange() }
            .onChange(of: bleManager.rightLoadAxel1) { _, _ in detectChange() }
        }.onReceive(bleManager.$isEnter) { newVealue in
            if newVealue {
                performEnterAction()
            }
        }
    }
    
    private func performEnterAction() {
        appendAxleData()
        hasChanged = false
        // Enter 누른 시점 Left, right, Axle 임시 저장
        lastTotal = (bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0)
        everExceeded100 = false
    }

    private func appendAxleData() {
        let currentAxles = [
            bleManager.leftLoadAxel1 ?? 0,
            bleManager.rightLoadAxel1 ?? 0
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
        let currentTotal = (bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0)
        let diff = abs(currentTotal - lastTotal)
        
        if diff >= 100 {
                everExceeded100 = true
            }
        if currentTotal == 0 {
                everExceeded100 = false
        }
        hasChanged = everExceeded100

    }
}

