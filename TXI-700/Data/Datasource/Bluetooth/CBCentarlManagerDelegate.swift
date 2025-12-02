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
            print("Connected to \(peripheral.name ?? "Unknown")")
        }

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
    
    func sendInitialSNCallCommand() {
        let bytes: [UInt8] = [0x42, 0x53, 0x4E]      // 'B' 'S' 'N'
        print("S/n : \(sendData(bytes))")
    }
    
    func sendInitialModeCallCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x4D]      // 'B' 'T' 'M'
        print("ModeCall : \(sendData(bytes))")
    }
    
    func sendInitialModeChangeCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x46]      // 'B', 'T', 'F'
        print("ModeChange : \(sendData(bytes))")
    }
    
    func sendInitialBatteryCheckCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x42]      // 'B', 'T', 'B'
        print("BatteryCheck : \(sendData(bytes))")
    }
    
    func sendInitialItemCommand(num: Int) {
        var bytes: [UInt8] = [0x42, 0x54, 0x51]      // 'B', 'T', 'Q'
        let numBytes = numTo2ByteAscii(num)
        bytes.append(contentsOf: numBytes)
        print("출력 확인 : \(num), \(numBytes)")
        print("ItemCheck : \(sendData(bytes))")
    }
    
    func sendItemSaveCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x49]      // 'B', 'T', 'I'
        print("ItemSave : \(sendData(bytes))")
    }
    
    func sendInitialClientCommand(num: Int) {
        var bytes: [UInt8] = [0x42, 0x54, 0x47]      // 'B', 'T', 'G'
        let numBytes = numTo2ByteAscii(num)
        bytes.append(contentsOf: numBytes)
        print("ClientCheck : \(sendData(bytes))")
    }
    
    func sendClientSaveCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x41]      // 'B', 'T', 'A'
        print("ClientSave : \(sendData(bytes))")
    }
    
    func sendInitialSettingCommand() {
        let bytes: [UInt8] = [0x42, 0x53, 0x54]      // 'B', 'S', 'T'
        print("Setting : \(sendData(bytes))")
    }
    
    func sendInitialSaveDataCommand() {
        let bytes: [UInt8] = [0x42, 0x44, 0x43]      // 'B', 'D', 'C'
        print("SaveData : \(sendData(bytes))")
    }
    
    func sendLangugeCommand(lang: Int) {
        let bytes: [UInt8] = {                      // 'B', 'T', 'U'
            switch lang {
            case 0:
                return [0x42, 0x54, 0x55, 0x00]
            case 1:
                return [0x42, 0x54, 0x55, 0x02]
            case 2:
                return [0x42, 0x54, 0x55, 0x01]
            default:
                return [0x42, 0x54, 0x55, 0x00]
            }
        }()
        print("Languge : \(sendData(bytes))")
    }
    
    func sendCancelCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x45]      // 'B', 'T', 'E'
        print("Cancel : \(sendData(bytes))")
    }
    
    func sendSumCommand() {
        let bytes: [UInt8] = [0x42, 0x54, 0x53]      // 'B', 'T', 'S'
        print("Sum Send Result: \(sendData(bytes))")
    }
    
    func sendEquipmentNumberCall() {
        let bytes: [UInt8] = [0x42, 0x43, 0x46]     // 'B', 'C', 'F'
        print("EquipmentNumber Call Send Result: \(sendData(bytes))")
    }
    
    
}
