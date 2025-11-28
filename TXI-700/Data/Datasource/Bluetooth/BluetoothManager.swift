//
//  BluetoothManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import Foundation
import CoreBluetooth
import CoreLocation
import Combine
import SwiftUI

class BluetoothManager: NSObject, ObservableObject{
    
    @Published var devices: [BLEDevice] = []
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedText: String = ""
    @Published var bluetoothPermissionStatus: PermissionStatus = .notDetermined
    @Published var locationPermissionStatus: PermissionStatus = .notDetermined
    @Published var bluetoothMac: String? = nil
    @Published var loadAxel1: Int? = nil
    @Published var loadAxel2: Int? = nil
    @Published var loadAxel3: Int? = nil
    @Published var loadAxel4: Int? = nil
    @Published var loadAxle1BatteryLevel: Int? = nil
    @Published var loadAxle2BatteryLevel: Int? = nil
    @Published var loadAxle3BatteryLevel: Int? = nil
    @Published var loadAxle4BatteryLevel: Int? = nil
    @Published var indicatorBatteryLevel: Int? = nil

    private var centralManager: CBCentralManager!
    private var locationManager: CLLocationManager!
    
    internal var targetCharacteristic: CBCharacteristic?
    
    let targetServiceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    let targetCharctersticUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    let targetCharcterstic2UUID = CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        checkLocationPermission()
    }
    
    // MARK: - Permissions
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationPermissionStatus = .authorized
        case .denied, .restricted:
            locationPermissionStatus = .denied
        case .notDetermined:
            locationPermissionStatus = .notDetermined
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            locationPermissionStatus = .denied
        }
    }
    
    func startScan() {
        stopScan()
        guard centralManager.state == .poweredOn else {
            print("BLE NOT READY")
            return
        }
        devices.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: [targetServiceUUID])
        print("Scanning Started")
    }
    
    func stopScan() {
        isScanning = false
        centralManager.stopScan()
        print("Scanning Stopped")
    }
    
    func connect(to device: BLEDevice) {
        connectedPeripheral = device.peripheral
        connectedPeripheral?.delegate = self
        isConnecting = true
        isConnected = true
        centralManager.connect(device.peripheral)
        print("Connecting to \(device.name)")
    }
    
    func disconnect() {
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
            print("Disconnecting from \(p.name ?? "Unknown")")
        } else {
            print("No connected peripheral to disconnect")
        }
        
        connectedPeripheral = nil
        isConnected = false
        isConnecting = false
    }
    
    func sendData(_ bytes: [UInt8]) -> Bool {
        guard targetCharacteristic != nil else {
                print("❌ Characteristic not ready yet")
                return false
            }
        
        guard let peripheral = connectedPeripheral,
              let characteristic = targetCharacteristic,
              peripheral.state == .connected else {
                print("하드웨어 Notify 준비가 안됨 → Write 무시")
                return false
            }
        
        let data = Data(bytes)
//        let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
//        let ascii = String(data: data, encoding: .utf8) ?? ""
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        return true
    }
}
