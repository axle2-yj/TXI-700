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
    
    var body: some View {
        Button("ENTER") {
            appendAxleData()
            hasChanged = false
        }
        .disabled(!hasChanged)
        .opacity(hasChanged ? 1.0 : 0.4)
        .onChange(of: bleManager.loadAxel1) {
            detectChange()
        }
        .onChange(of: bleManager.loadAxel2) {
            detectChange()
        }
        .onChange(of: bleManager.loadAxel3) {
            detectChange()
        }
        .onChange(of: bleManager.loadAxel4) {
            detectChange()
        }
    }
    
    // MARK: - 데이터 추가
    private func appendAxleData() {
        let currentAxles = [
            bleManager.loadAxel1 ?? 0,
            bleManager.loadAxel2 ?? 0,
            bleManager.loadAxel3 ?? 0,
            bleManager.loadAxel4 ?? 0
        ]
        
        if let last = loadAxleStatus.last, last.loadAxlesData.count < 4 {
            // 마지막 항목에 이어서 저장
            var updatedAxles = last.loadAxlesData
            
            // 4개까지 이어서 채움
            for axle in currentAxles {
                if updatedAxles.count < 4 {
                    updatedAxles.append(axle)
                }
            }
            
            let updated = LoadAxleStatus(
                id: last.id,
                loadAxlesData: updatedAxles,
                total: updatedAxles.reduce(0, +)
            )
            
            loadAxleStatus[loadAxleStatus.count - 1] = updated
        } else {
            // 새 항목 생성
            let newStatus = LoadAxleStatus(
                id: loadAxleStatus.count + 1,
                loadAxlesData: currentAxles.prefix(4).map { $0 }, // 최대 4개
                total: currentAxles.prefix(4).reduce(0, +)
            )
            loadAxleStatus.append(newStatus)
        }
        
        // BLE 값 초기화
        bleManager.loadAxel1 = 0
        bleManager.loadAxel2 = 0
        bleManager.loadAxel3 = 0
        bleManager.loadAxel4 = 0
    }

    
    // MARK: - 변화 감지
    private func detectChange() {
        let currentTotal = (bleManager.loadAxel1 ?? 0) + (bleManager.loadAxel2 ?? 0)
        guard let last = loadAxleStatus.last else {
            hasChanged = true
            return
        }
        if currentTotal != last.total {
            hasChanged = true
        }
    }
}
