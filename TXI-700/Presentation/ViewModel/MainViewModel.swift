//
//  MainViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Foundation
import Combine

enum ActiveMainAlert: Identifiable {
    case printResponse(String)
    case success(String)
    case error(String)

    var id: String {
        switch self {
        case .printResponse(let msg):
            return "\(msg)"
        case .success:
            return "success"
        case .error:
            return "error"
        }
    }

    /// Alert에 표시할 메시지
    var message: String {
        switch self {
        case .printResponse(let msg),
             .success(let msg),
             .error(let msg):
            return msg
        }
    }
}

@MainActor
class MainViewModel: ObservableObject {
    @Published var text: String = NSLocalizedString("MainScreenTitle", comment: "")
    @Published var savedMac: String? = nil
    @Published var saveProduct: String? = nil
    @Published var saveClient: String? = nil
    @Published var sn: Int = 0
    private var batteryTimer: Timer?
    // Mac Address 호출
    func loadDeviceMac() {
        savedMac = StorageManager.shared.loadMacAddress()
    }
    
    // Mac Address  초기화
    func clearMac() {
        StorageManager.shared.clearMacAddress()
        savedMac = nil
    }
    
    // Product명 호출
    func loadProduct() {
        saveProduct = StorageManager.shared.loadProductTitle()
    }
    
    // Client명 호출
    func loadClient() {
        saveClient = StorageManager.shared.loadClientTitle()
    }
    
    func saveSn(_ sn: Int) {
        StorageManager.shared.saveSerialNumber(sn)
    }
    
    func loadSn() {
        sn = StorageManager.shared.loadSerialNumber()
    }
    
    // Indicator 베터리 출력 30초 마다 호출
    func startTimer(bleManager: BluetoothManager) {
        batteryTimer?.invalidate()
        batteryTimer = nil
        
        // 0.5초 후에 1회 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task { @MainActor in
                bleManager.sendInitialBatteryCheckCommand()
            }
        }
        batteryTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
               Task { @MainActor in
                   bleManager.sendInitialBatteryCheckCommand()
               }
           }
    }
    
    func handleInmotion(
            loadAxleStatus: inout [LoadAxleStatus],
            left: Int,
            right: Int
    ) {
        let currentAxles = [left, right]
        
        if var last = loadAxleStatus.last {
            for axle in currentAxles where last.loadAxlesData.count < 20 {
                last.loadAxlesData.append(axle)
            }
            last.total = last.loadAxlesData.reduce(0, +)
            loadAxleStatus[loadAxleStatus.count - 1] = last
        } else {
            loadAxleStatus.append(
                LoadAxleStatus(
                    id: 1,
                    loadAxlesData: currentAxles,
                    total: currentAxles.reduce(0, +)
                )
            )
        }
    }
}

