//
//  CBCentarlManagerDelegate.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import Foundation
import CoreBluetooth

extension BluetoothManager: CBCentralManagerDelegate {
    
    // MARK: - Bluetooth 상태 변경
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothPermissionStatus = .authorized
            print("Bluetooth ON")
            
            guard autoConnectEnabled else { return }
            print("자동실행 1단계: tryImmediateReconnect() 호출")
            
            // 즉시 재연결 시도
            tryImmediateReconnect()
            
        case .unauthorized:
            bluetoothPermissionStatus = .denied
            print("Bluetooth Unauthorized")
            
        default:
            bluetoothPermissionStatus = .notDetermined
            print("Bluetooth Not Ready")
        }
    }
    
    
    // MARK: - 장치 발견 (스캔 중)
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        let device = BLEDevice(id: peripheral.identifier,
                               name: peripheral.name ?? "Unknown",
                               peripheral: peripheral)
        
        DispatchQueue.main.async {
            
            // 목록 중복 방지
            if !self.devices.contains(where: { $0.id == device.id }) {
                self.devices.append(device)
                print("Discovered: \(device.name)")
            }
            
            // 자동 연결
            if self.autoConnectEnabled,
               let saved = self.savedMac,
               saved == peripheral.identifier.uuidString,
               !self.isConnected,
               !self.isConnecting {
                
                print("Auto-connecting to saved device: \(device.name)")
                
                // 백그라운드 → 메인은 delegate callback이 처리함
                self.connect(to: device)
                self.stopScan()
            }
        }
    }
    
    
    // MARK: - 연결 성공
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
            self.isConnected = true
            self.isConnecting = false
            self.isDisconnected = false
            print("Connected to \(peripheral.name ?? "Unknown")")
        }
        // 🔐 1. 아이폰 고유 키 준비 (없으면 생성)
        let deviceUUID = BLEKeyManager.shared.getDeviceUUID()
        //        sendCommand(.xxx(deviceUUID), log: "Id Check Send")
        print("deviceUUID " + deviceUUID)
        
        peripheral.delegate = self
        peripheral.discoverServices([targetServiceUUID])
    }
    
    
    // MARK: - 연결 실패
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
        }
        
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown")")
        
        if autoConnectEnabled {
            tryImmediateReconnect()
        }
    }
    
    
    // MARK: - 연결 끊김
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        
        DispatchQueue.main.async {
            self.connectedPeripheral = nil
            self.isConnected = false
            self.isConnecting = false
            self.isDisconnected = true
            print("Disconnected")
        }
        
        guard autoConnectEnabled else { return }
        
        print("자동 재연결 시작")
        
        // 1단계 → 캐시 즉시 재연결
        tryImmediateReconnect()
        
        // 2단계 → 그래도 안 되면 스캔
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !self.isConnected {
                print("캐시 연결 실패 → 스캔 시작")
                self.startScan()
            }
        }
    }
    
    @discardableResult
    func sendCommand(_ command: BLECommand, log: String? = nil) -> Bool {
        let result = send(command)
        if let log {
            print("🔥 \(log): \(result)")
        }
        return result
    }
    // bst 추가 필요
}
