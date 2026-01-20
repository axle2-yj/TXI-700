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

final class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - Published States
    @Published var devices: [BLEDevice] = []
    @Published var isScanning = false
    @Published var isSelfScanning = false
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var isDisconnected = true
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedText: String = ""
    @Published var bluetoothPermissionStatus: PermissionStatus = .notDetermined
    @Published var locationPermissionStatus: PermissionStatus = .notDetermined
    
    @Published var bluetoothMac: String? = nil
    @Published var axles: [Int: AxleState] = [:] // 1~8
    @Published var weightMode: WeightMode = .staticMode
    @Published var indicatorBatteryLevel: Int? = nil
    @Published var inmotion: Int = 0
    
    @Published var savedMac: String? = nil
    @Published var autoConnectEnabled: Bool = false
    @Published var bsnResult: String = ""
    
    weak var eventHandler: BLEEventHandling?
    
    @Published var indicatorState: IndicatorState = .idle
    @Published var printResponse: String = ""
    @Published var modeChangeInt = 0
    @Published var modeChangeResponse = false
    @Published var SnNumber = 0
    @Published var IndicatorSnNumber = 0
    @Published var IndicatorModelNum = ""
    @Published var equipmentVer: String = ""
    @Published var equipmentNumber: String = ""
    @Published var equipmentSubNumber: String = ""
    @Published var rfMassage: String = ""
    @Published var isAuthenticated = false
    @Published var lastResponse: BLEResponse?
    @Published var showAuthAlert = false
    @Published var isUnapprovedModel = false
    
    // MARK: - Private Managers
    private var centralManager: CBCentralManager!
    private var locationManager: CLLocationManager!
    
    private var notifyChar: CBCharacteristic?
    private var writeChar: CBCharacteristic?
    private var authChallengeChar: CBCharacteristic?
    var authResponseChar: CBCharacteristic?
    var authTimeoutWorkItem: DispatchWorkItem?
    
    // MARK: - Combine 전용 Publisher
    var axlesPublisher: AnyPublisher<[AxleState], Never> {
        $axles
            .map { Array($0.values) }
            .eraseToAnyPublisher()
    }
    
    var weightModePublisher: AnyPublisher<WeightMode, Never> {
        $weightMode.eraseToAnyPublisher()
    }
    
    // MARK: - BLE Characteristic
    internal var targetCharacteristic: CBCharacteristic?
    
    // MARK: - UUIDs
    let targetServiceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    let targetCharctersticUUID1 = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    let targetCharctersticUUID2 = CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB")
    
    // MARK: - Auth UUID
    let authServiceUUID   = CBUUID(string: "0000AAA0-0000-1000-8000-00805F9B34FB")
    let authChallengeUUID = CBUUID(string: "0000AAA1-0000-1000-8000-00805F9B34FB") // Notify
    let authResponseUUID  = CBUUID(string: "0000AAA2-0000-1000-8000-00805F9B34FB") // Write
    
    // MARK: - Init
    override init() {
        super.init()
        
        // Central Manager는 main queue 추천 (UI 연동 자연스럽고 delegate 호출 안전)
        centralManager = CBCentralManager(delegate: self, queue: .main)
        
        // Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        checkLocationPermission()
        
        for i in 1...8 {
            axles[i] = .empty(axle: i)
        }
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
        
        centralManager.scanForPeripherals(
            withServices: [targetServiceUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ]
        )
        
        print("Scanning Started")
    }
    
    func stopScan() {
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            print("Scanning Stopped")
        }
    }
    
    
    // MARK: - Connect & Disconnect
    func connect(to device: BLEDevice) {
        
        if isConnecting || isConnected {
            print("Already connected/connecting. Skip connect()")
            return
        }
        
        connectedPeripheral = device.peripheral
        connectedPeripheral?.delegate = self
        isConnecting = true
        isConnected = false
        
        print("Connecting to \(device.name)")
        centralManager.connect(device.peripheral)
    }
    
    func disconnect() {
        guard let p = connectedPeripheral else {
            print("No connected peripheral to disconnect")
            return
        }
        
        centralManager.cancelPeripheralConnection(p)
        print("Disconnecting from \(p.name ?? "Unknown")")
        
        connectedPeripheral = nil
        isConnected = false
        isConnecting = false
    }
    
    
    // MARK: - Write
    func sendData(_ bytes: [UInt8]) -> Bool {
        
        guard let characteristic = targetCharacteristic,
              let peripheral = connectedPeripheral else {
            print("Characteristic or Peripheral not ready")
            return false
        }
        
        guard peripheral.state == .connected else {
            print("Peripheral is not connected → write ignored")
            return false
        }
        
        let data = Data(bytes)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        
        return true
    }
    
    func send(_ command: BLECommand) -> Bool {
        return sendData(command.bytes)
    }
    
    
    // MARK: - Fast Reconnect
    func tryImmediateReconnect() {
        
        guard let saved = savedMac,
              let uuid = UUID(uuidString: saved) else {
            print("No saved UUID → scanning")
            startScan()
            return
        }
        
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        
        if let cached = peripherals.first {
            print("Cached peripheral found → fast reconnect")
            
            let device = BLEDevice(id: cached.identifier,
                                   name: cached.name ?? "Unknown",
                                   peripheral: cached)
            connect(to: device)
            
        } else {
            print("No cached peripheral → scanning")
            startScan()
        }
    }
    
    func sendToJsonCommand(items: [PrintPayload]) {
        
        guard let peripheral = connectedPeripheral,
              let characteristic = targetCharacteristic,
              peripheral.state == .connected else {
            print("❌ BLE not ready")
            return
        }
        
        let wrapper = PrintPayloadWrapper(list: items)
        
        do {
            let jsonData = try JSONEncoder().encode(wrapper)
            
            BLEChunkSender.sendJSON(
                jsonData,
                peripheral: peripheral,
                characteristic: characteristic
            )
            
            print("✅ BLE JSON sent")
            
        } catch {
            print("❌ JSON encode failed:", error)
        }
    }
}
