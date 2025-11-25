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

    private var centralManager: CBCentralManager!
    private var locationManager: CLLocationManager!
    
    internal var targetCharacteristic: CBCharacteristic?
    let targetServiceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    
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
    
    // MARK: - Scan
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
    
    // MARK: - Connect
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
}
