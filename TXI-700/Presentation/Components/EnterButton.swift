//
//  EnterButton.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import SwiftUI
import Foundation

struct EnterButton: View {
    @EnvironmentObject var bleManager: BluetoothManager
    @Binding var loadAxleStatus: [LoadAxleStatus]
    
    @State private var hasChanged: Bool = false
    @State private var lastTotal: Int = 0  // Enter 누른 시점의 합 저장
    @State private var everExceeded100: Bool = false  // ← 한 번이라도 100kg 이상 차이 발생

    var body: some View {
        Button("ENTER") {
            appendAxleData()
            hasChanged = false
            // Enter 누른 시점 total 갱신
            lastTotal = (bleManager.leftLoadAxel1 ?? 0) + (bleManager.rightLoadAxel1 ?? 0)
            everExceeded100 = false
        }.frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(6)
        .foregroundColor(.black)
        .disabled(!hasChanged)
        .opacity(hasChanged ? 1.0 : 0.4)
        .onChange(of: bleManager.leftLoadAxel1) { _, _ in detectChange() }
        .onChange(of: bleManager.rightLoadAxel1) { _, _ in detectChange() }
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

