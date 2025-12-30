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
            
            if characteristic.uuid == targetCharctersticUUID {
                // FFF1 → Notify
                print("Notify characteristic found: FFF1")
                peripheral.setNotifyValue(true, for: characteristic)
            }

            if characteristic.uuid == targetCharcterstic2UUID {
                // FFF2 → Write
                print("Write characteristic found: FFF2")
                self.targetCharacteristic = characteristic
            }
            
            
            print("Characteristic found: \(characteristic.uuid)")
            
            if let error = error {
                    print("Data write failed: \(error.localizedDescription)")
            } else {
                print("Data write succeeded for characteristic: \(characteristic.uuid)")
                sendInitialModeCallCommand()
                sendInitialSNCallCommand()
                sendEquipmentNumberCall()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error { print("Value update error: \(error)"); return }
        guard let data = characteristic.value else { return }
        let bytes = [UInt8](data)

        // 프로토콜 응답
        let response = BLEParser.parse(bytes)
        handle(response)
        
        // 실시간 계측 데이터
        parseWeight(bytes)
        
        if characteristic.uuid == targetCharctersticUUID {
            parseAxleBattery(bytes)
        }
    }
    
    private func handle(_ response: BLEResponse) {
        switch response {
        case .enterOrCancel:
            if !isSum {
                isEnter = true
                isCancel = false
                print("🔥 BTE result → ENTER" )
            } else {
                isPrint = false
                isSum = false
                isCancel = true
                print("🔥 BTE result → CANCEL" )
            }
        case .sumOrPrint:
            if isSum {
                isSum = false
                isEnter = false
                print("🔥 BTN result → PRINT" )
            } else {
                isSum = true
                isEnter = false
                print("🔥 BTN result → SUM \(isSum)" )
            }
        case .staticMode:
            print("🔥 WMS result → Static")                         // Mode Static
            modeChangeResponse = true
            modeChangeInt = WeightMode.staticMode.rawValue
        case .inmotionMode:
            print("🔥 WMS result → Inmotion")                       // Mode Inmotion
            modeChangeResponse = true
            modeChangeInt = WeightMode.inmotionMode.rawValue
        case .autoInmotionMode:
            print("🔥 WMS result → Auto Inmotion")                  // Mode Auto Inmotion
            modeChangeResponse = true
            modeChangeInt = WeightMode.autoInmotionMode.rawValue
        case .battery(let level):
            DispatchQueue.main.async {
                self.indicatorBatteryLevel = level
            }
        case .itemCall(let value):
            let resultString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("🔥 Item result →", resultString)
            }
        case .clientCall(let value):
            let resultString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("🔥 Client result →", resultString)
            }
        case .headlineDeleted:
            isDelete = true
            print("🔥 Headline Deleted Result → HadLine Title Delete")
        case .headlineSaved:
            isDelete = false
            print("🔥 Headline Saved Result → HadLine Title Save Success")
        case .printSend:
            printResponse = "Print Send Success"
            print("🔥 PTS result → Print Send Success")              // 프린터 수신완료
        case .printErrorCommunication:
            printResponse = "Print Error(Communication)"
            print("🔥 PTE result → Print Error(Communication)")      // 프린터 에러(통신 에러)
        case .printing:
            printResponse = "Printing in progress"
            print("🔥 PTI result → Printing in progress")                    // 프린터 중
        case .printErrorPaper:
            printResponse = "Print Error(No Paper))"
            print("🔥 PTP result → Print Error(No Paper)")          // 프린터 에러(용지 없음)
        case .printSuccess:
            printResponse = "Print Success"
            print("🔥 PTC result → Print Success")                  // 프린터 정상완료
        case .sirealNumberCecke:
            print("🔥 BSN result → S/N")
        case .equipment(let value):
            let part1 = String(bytes: value[0..<3], encoding: .ascii)!
            let part2 = String(bytes: value[3..<9], encoding: .ascii)!
            let part3 = String(bytes: value[9..<11], encoding: .ascii)!
            equipmentVer = part1
            equipmentNumber = part2
//            print("🔥 Equipment Number Call result → Equipment Number Call : \(result)")
            print("🔥 Equipment Version Call result → Equipment Version Call : \(part1)")           // 장비 소프트웨어 버전
            print("🔥 Equipment S/N Number Call result → Equipment S/N Number Call : \(part2)")     // 장비 고유번호
            print("🔥 Equipment Sub Number Call result → Equipment Sub Number Call : \(part3)")     // 장비 등록번호
        case .rf(let value):
            let resultString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("🔥 RF result →", resultString)
                self.rfMassage = resultString  // SwiftUI 업데이트용
            }
        default : break
        }
    }
//    func parseResponse(_ bytes: [UInt8]) {
//        if bytes.count < 3 { return }
//        
//        if bytes.count >= 3,
//           bytes[0] == 0x52,    // R
//           bytes[1] == 0x46 {   // F
//            let result = bytes.dropFirst(2)
//            
//            //  String 변환
//            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
//            DispatchQueue.main.async {
//                print("RF result →", resultString)
//                self.rf = resultString  // SwiftUI 업데이트용
//            }
//        }
//        
//        if bytes.count >= 3,
//           bytes[0] == 0x42,    // B
//           bytes[1] == 0x54,    // T
//           bytes[2] == 0x49 {   // I
//            let result = bytes.dropFirst(3)
//            //  String 변환
//            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
//            DispatchQueue.main.async {
//                print("Product result →", resultString)
//            }
//        }
//        
//        if bytes.count >= 3,
//           bytes[0] == 0x42,    // B
//           bytes[1] == 0x54,    // T
//           bytes[2] == 0x41 {   // A
//            let result = bytes.dropFirst(3)
//            //  String 변환
//            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
//            DispatchQueue.main.async {
//                print("Client result →", resultString)
//            }
//        }
//        
//        if bytes.count >= 3,
//           bytes[0] == 0x42,    // B
//           bytes[1] == 0x54,    // T
//           bytes[2] == 0x43 {   // C
//            let result = bytes.dropFirst(3)
//            //  String 변환
//            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
//            DispatchQueue.main.async {
//                print("Vehcile result →", resultString)
//            }
//        }
//    }
    
    private func parseWeight(_ bytes: [UInt8]) {
        guard bytes.count > 13 else { return }
                       
        // sequence
        let sequence = Int(bytes[3])
        
        if sequence != 0 {
            inmotion = Int(sequence)
        }
        
        let sensorIndex = Int(bytes[2])
            let axle = (sensorIndex + 1) / 2
            let isLeft = sensorIndex % 2 == 1

            let isNegative = bytes[5] == 32
            let numericBytes = bytes[8...12]
            let numericString = numericBytes.compactMap {
                String(UnicodeScalar($0))
            }.joined()

            guard let number = Int(numericString) else { return }
            let value = isNegative ? -number : number

        DispatchQueue.main.async {
                var state = self.axles[axle] ?? AxleState(
                    axle: axle,
                    leftWeight: nil,
                    rightWeight: nil,
                    leftBatteryLevel: nil,
                    rightBatteryLevel: nil
                )

                if isLeft {
                    state.leftWeight = value
                } else {
                    state.rightWeight = value
                }

                self.axles[axle] = state
            }
    }
    
    private func parseAxleBattery(_ bytes: [UInt8]) {
        guard bytes.count >= 8 else { return }
        
        let sensorIndex = Int(bytes[2])
        let axle = (sensorIndex + 1) / 2
        let isLeft = sensorIndex % 2 == 1
        let level = Int(bytes[7])
        
        DispatchQueue.main.async {
                var state = self.axles[axle] ?? AxleState(
                    axle: axle,
                    leftWeight: nil,
                    rightWeight: nil,
                    leftBatteryLevel: nil,
                    rightBatteryLevel: nil
                )

                if isLeft {
                    state.leftBatteryLevel = level
                } else {
                    state.rightBatteryLevel = level
                }

                self.axles[axle] = state
            }
    }
}
