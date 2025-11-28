//
//  CBPeripheralDelegate.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import Foundation
import CoreBluetooth

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Service discovery error: \(error)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Discovered service: \(service.uuid)")
            
            // 모든 서비스에서 characteristics 탐색
            peripheral.discoverCharacteristics(nil, for: service)
            
            // 배터리 서비스일 경우 배터리 레벨 characteristics 탐색
            if service.uuid == targetServiceUUID {
                peripheral.discoverCharacteristics([targetServiceUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let error = error { print("Characteristic discovery error: \(error)"); return }
        service.characteristics?.forEach { characteristic in
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                targetCharacteristic = characteristic
            }
            
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                print("Write characteristic found: \(characteristic.uuid)")
                self.targetCharacteristic = characteristic
            }
            
            print("Characteristic found: \(characteristic.uuid)")
            
            if let error = error {
                    print("Data write failed: \(error.localizedDescription)")
                } else {
                    print("Data write succeeded for characteristic: \(characteristic.uuid)")
                }
            
            switch characteristic.uuid {
            case targetCharctersticUUID:
                if let data = characteristic.value {
                    let battery = Int(data.first ?? 0)
                    DispatchQueue.main.async {
                        self.loadAxle1BatteryLevel = battery
                    }
                }

            case targetCharctersticUUID:
                if let data = characteristic.value {
                    let battery = Int(data.first ?? 0)
                    DispatchQueue.main.async {
                        self.loadAxle2BatteryLevel = battery
                    }
                }
            case targetServiceUUID:
                if let data = characteristic.value {
                    let battery = Int(data.first ?? 0)
                    DispatchQueue.main.async {
                        self.indicatorBatteryLevel = battery
                    }
                }
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error { print("Value update error: \(error)"); return }
        guard let data = characteristic.value else { return }
        let bytes = [UInt8](data)
        guard bytes.count >= 9 else { return } // 최소 9바이트 이상이어야 함

        // 4번째 바이트 기준으로 음수/양수 판단
        let signByte = bytes[3]
        let isNegative = (signByte == 26) // 26이면 음수, 18이면 양수

        // 끝 5자리 숫자 추출
        let numericBytes = bytes[4...8]   // 48,48,48,56,48
        let numericString = numericBytes.compactMap { String(UnicodeScalar($0)) }.joined()

        if let number = Int(numericString) {
            let realValue = isNegative ? -number : number
            DispatchQueue.main.async {
                self.receivedText = "\(realValue)"
                self.loadAxel1 = realValue
                self.loadAxel2 = realValue
            }
        }
        
        if characteristic.uuid == targetCharctersticUUID {
            if let value = characteristic.value {
                    let battery = value.first ?? 0
                    DispatchQueue.main.async {
                        self.loadAxle1BatteryLevel = Int(battery)
                    }
                }
        }
    }
}
