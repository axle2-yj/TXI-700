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
        sendIdCheckCommand(deviceUUID)
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
    
    func sendInitialSNCallCommand() {
        print("S/n : \(send(.bsn))")
    }
    
    func sendInitialModeCallCommand() {
        print("ModeCall : \(send(.btm))")
    }
    
    func sendInitialModeChangeCommand() {
        print("ModeChange : \(send(.btf))")
    }
    
    func sendInitialBatteryCheckCommand() {
        print("BatteryCheck : \(send(.btb))")
    }
    
    func sendZeroCommand() {
        print("ZeroButton : \(send(.btz))")
    }
    
    func sendInitialItemCommand(num: Int) {
        print("ItemCheck : \(send(.btq(num)))")
    }
        
    func sendInitialClientCommand(num: Int) {
        print("ClientCheck : \(send(.btg(num)))")
    }
        
    func sendInitialSettingCommand() {
        print("Setting : \(send(.bst))")
    }
    
    func sendInitialSaveDataCommand() {
        print("SaveData : \(send(.bdc))")
    }
    
    func sendLangugeCommand(lang: Int) {
        print("Languge : \(send(.btu(lang)))")
    }
    
    func sendCancelCommand() {
        print("Cancel : \(send(.bte))")
    }
    
    func sendSumCommand() {
        print("Sum Send Result: \(send(.bts))")
    }
    
    func sendEquipmentNumberCall() {
        print("EquipmentNumber Call Send Result: \(send(.bcf))")
    }
    
    func sendPrintHeadLineCommand(title: String) {
        print("PrintHeadLine Send Result: \(send(.bth(title)))")
    }
    
    func sendPrintHeadLineDeleteCommand() {
        print("PrintHeadLineDelete Send Result: \(send(.btd))")
    }
    
    func sendPrintAndSumCommand() {
        print("PrintIndicator Send Result: \(send(.bts))")
    }
    
    func sendPrintOneLineStartCommand(text: String) {
        print("PrintOneLine Start Send Result: \(send(.wps(text)))")
    }
    
    func sendPrintOneLineLastCommand(text: String) {
        print("PrintOneLine Last Send Result: \(send(.wpt(text)))")
    }
    
    func sendPrintOneLineCommand(text: String) {
        print("PrintOneLine Send Result: \(send(.wpe(text)))")
    }
    
    func sendVehicleSaveCommand(name: String) {
        print("Vehicle Save Send: \(send(.btc(name)))")
    }
    
    func sendItemSaveCommand(num: Int, name: String) {
        print("Item Save Send: \(send(.bti(num: num, name: name)))")
    }
    
    func sendClientSaveCommand(num: Int, name: String) {
        print("Item Save Send: \(send(.bta(num: num, name: name)))")
    }
    
    func sendPowerOffCommand() {
        print("Power Off Send: \(send(.btp))")
    }
    
    func sendIdCheckCommand(_ text: String) {
        print("Id Check Send: \(send(.xxx(text)))")
    }
}
