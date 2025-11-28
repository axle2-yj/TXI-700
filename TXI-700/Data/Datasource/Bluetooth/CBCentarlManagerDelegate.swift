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
        case .unauthorized:
            bluetoothPermissionStatus = .denied
            print("Bluetooth Unauthorized")
        default:
            bluetoothPermissionStatus = .notDetermined
            print("Bluetooth Not Ready")
        }
    }
    
    // MARK: - 장치 발견
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let device = BLEDevice(id: peripheral.identifier,
                               name: peripheral.name ?? "Unknown",
                               peripheral: peripheral)
        
        DispatchQueue.main.async {
            if !self.devices.contains(where: { $0.id == device.id }) {
                self.devices.append(device)
                print("Discovered: \(device.name)")
            }
        }
    }
    
    // MARK: - 연결 성공
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral     
        isConnected = true
        isConnecting = false
        peripheral.delegate = self
        peripheral.discoverServices([targetServiceUUID])
        print("Connected to \(peripheral.name ?? "Unknown")")
    }
    
    // MARK: - 연결 실패
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        connectedPeripheral = nil
        isConnected = false
        isConnecting = false
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown")")
    }
    
    // MARK: - 연결 끊김
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        connectedPeripheral = nil
        isConnected = false
        isConnecting = false
        print("Disconnected")
    }
}
