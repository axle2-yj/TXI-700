//
//  HomeViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Foundation
import Combine

enum ActiveHomeAlert: Identifiable {
    case success(String)
    case error(String)
    
    var id: String {
        switch self {
        case .success(let msg):
            return "\(msg)"
        case .error(let msg):
            //            return "error"
            return "\(msg)"
        }
    }
    
    /// Alert에 표시할 메시지
    var message: String {
        switch self {
        case .success(let msg),
                .error(let msg):
            return msg
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var text: String = NSLocalizedString("HomeScreenTitle", comment: "")
    @Published var savedMAC: String? = nil
    @Published var autoConnectEnabled: Bool = false
    
    private var scanTimer: Timer?
    private var isScanning = false
    private weak var bleManager: BluetoothManager?
    
    func saveDeviceMac(_ mac: String) {
        print("mac : \(mac)")
        StorageManager.shared.saveMacAddress(mac)
        // 저장 후 바로 로컬 변수에 반영
        savedMAC = mac
    }
    
    func loadDeviceMac() {
        savedMAC = StorageManager.shared.loadMacAddress()
    }
    
    func clearMac() {
        StorageManager.shared.clearMacAddress()
        savedMAC = nil
    }
    
    func setBleManager(_ manager: BluetoothManager) {
        self.bleManager = manager
    }
    
    func startAutoConnect() {
        guard autoConnectEnabled else { return }
        scheduleScanCycle()
    }
    
    func stopAutoConnect() {
        scanTimer?.invalidate()
        scanTimer = nil
    }
    
    func setAutoConnectState(_ isEnabled: Bool) {
        autoConnectEnabled = isEnabled
        StorageManager.shared.saveAutoScan(isEnabled)
        //        if !isEnabled {
        //            StorageManager.shared.saveMacAddress("")
        //        }
    }
    
    func loadAutoConnectState() {
        autoConnectEnabled = StorageManager.shared.loadAutoScan()
        print(autoConnectEnabled)
    }
    
    private func scheduleScanCycle() {
        // 5초 스캔
        scanTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self else { return }
            
            Task { @MainActor in
                self.autoStartScan()
            }
        }
    }
    
    private func autoStartScan() {
        guard autoConnectEnabled, let bleManager else { return }
        isScanning = true
        bleManager.startScan()
        
        // 10초 후 스캔 중지
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.bleManager?.stopScan()
            self?.isScanning = false
            self?.checkForSavedDevice()
            
            // 20초 휴식 후 다음 스캔
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if !bleManager.isConnected {
                    self?.scheduleScanCycle()
                }
            }
        }
    }
    
    private func checkForSavedDevice() {
        guard let bleManager, let savedMAC else { return }
        if let device = bleManager.devices.first(where: { $0.mac == savedMAC }) {
            bleManager.connect(to: device)
            print("Device found. Connecting...")
        } else {
            print("Device not found.")
        }
    }
}
