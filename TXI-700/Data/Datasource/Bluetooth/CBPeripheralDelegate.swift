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

        parseResponse(bytes)
//        print ("\(bytes)")
        guard bytes.count >= 9 else { return } // 최소 9바이트 이상이어야 함
        // 4번째 바이트 기준으로 음수/양수 판단
        let signByte = bytes[5]
        let isNegative = signByte == 32//(signByte == 24 || signByte == 26)

        // 끝 5자리 숫자 추출
        let numericBytes = bytes[8...12]   // 48,48,48,56,48
        let numericString = numericBytes.compactMap { String(UnicodeScalar($0)) }.joined()

        if let number = Int(numericString) {
            let realValue = isNegative ? -number : number
            DispatchQueue.main.async {
                switch bytes[2] {
                case 1:
                    self.leftLoadAxel1 = realValue
                case 2:
                    self.rightLoadAxel1 = realValue
                case 3:
                    self.leftLoadAxel2 = realValue
                case 4:
                    self.rightLoadAxel2 = realValue
                default :
                    break
                }
            }
        }
        
        if characteristic.uuid == targetCharctersticUUID {
            if let value = characteristic.value {
                    let battery = Int(data[7])
                    DispatchQueue.main.async {
                        switch value[2] {
                        case 1:
                            self.loadAxle1BatteryLevel = battery
                        case 2:
                            self.loadAxle2BatteryLevel = battery
                        case 3:
                            self.loadAxle3BatteryLevel = battery
                        case 4:
                            self.loadAxle4BatteryLevel = battery
                        default :
                            break
                        }
                    }
                }
        }
    }
    
    func parseResponse(_ bytes: [UInt8]) {
        if bytes.count < 3 { return }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,   // 'B'
           bytes[1] == 0x54,   // 'T'
           bytes[2] == 0x45 {  // 'E'
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
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,   // 'B'
           bytes[1] == 0x54,   // 'T'
           bytes[2] == 0x53 {  // 'S'
            
            if isSum {
                print("🔥 BTN result → PRINT")
                isSum = false
                isEnter = false
            } else {
                print("🔥 BTN result → SUM")
                isSum = true
                isEnter = false
            }
            
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,   // 'B'
           bytes[1] == 0x53,   // 'S'
           bytes[2] == 0x4E {  // 'N'
            print("🔥 BSN result → S/N")
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x57,   // 'W'
           bytes[1] == 0x4D {  // 'M'
            switch bytes[2] {
            case 0x53:
                print("🔥 WMS result → Static")                         // Mode Static
                modeChangeResponse = true
                modeChangeInt = 0
            case 0x57:
                print("🔥 WMS result → Inmotion")                       // Mode Inmotion
                modeChangeResponse = true
                modeChangeInt = 1
            case 0x41:
                print("🔥 WMS result → Auto Inmotion")                  // Mode Auto Inmotion
                modeChangeResponse = true
                modeChangeInt = 2
            default:
                break
                
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x53,
            bytes[1] == 0x4E{
            let result = bytes.dropFirst(2)
            print("🔥 SN result → \(result)")                           // S/N 정보
            let number = result.reduce(0) { $0 * 10 + $1 }
            SnNumber = (Int(number) + 1)
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,
            bytes[1] == 0x41{
            let result = bytes.dropFirst(2)
            DispatchQueue.main.async {
                self.indicatorBatteryLevel = Int(result.first ?? 0)     // Indicator 배터리 잔량
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x50,
            bytes[1] == 0x54{
            switch bytes[2] {
            case 0x53:
                printResponse = "Print Send Success"
                print("🔥 PTS result → Print Send Success")              // 프린터 수신완료
            case 0x45:
                printResponse = "Print Error(Communication)"
                print("🔥 PTE result → Print Error(Communication)")      // 프린터 에러(통신 에러)
            case 0x49:
                printResponse = "Printers among"
                print("🔥 PTI result → Printers among")                    // 프린터 중
            case 0x50:
                printResponse = "Print Error(No Paper))"
                print("🔥 PTP result → Print Error(No Paper)")          // 프린터 에러(용지 없음)
            case 0x43:
                printResponse = "Print Success"
                print("🔥 PTC result → Print Success")                  // 프린터 정상완료
            default:
                break
            }
        }
        
        
        if bytes.count >= 3,
           bytes[0] == 0x42,   // 'B'
           bytes[1] == 0x54,   // 'T'
           bytes[2] == 0x44 {  // 'D'
            //            let result = bytes.dropFirst(3)
            isDelete = true
            print("🔥 BTD result → HadLine Title Delete")               // HeadLine Title 삭제

            // 예: String 변환
            //            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            //            DispatchQueue.main.async {
            //                print("🔥 BTM result →", resultString)
            //                self.bsnResult = resultString  // SwiftUI 업데이트용
            //            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,   // 'B'
           bytes[1] == 0x54,   // 'T'
           bytes[2] == 0x48 {  // 'H'
//            let result = bytes.dropFirst(3)
            isDelete = false
            print("🔥 BTH result → HadLine Title Success")               // HeadLine Title 저장 성공
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x49,    // I
           bytes[1] == 0x54 {   // T
            let result = bytes.dropFirst(2)
            print("🔥 IT result → Item Call : \(result)")               //
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("Product result →", resultString)
            }
        }
        if bytes.count >= 3,
           bytes[0] == 0x43,    // C
           bytes[1] == 0x4C {   // L
            let result = bytes.dropFirst(2)
            print("🔥 CL result → Client Call : \(result)")               //
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("Product result →", resultString)
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,    // B
           bytes[1] == 0x53,    // S
           bytes[2] == 0x54 {   // T
            let result = bytes.dropFirst(3)
            print("🔥 Setting result → Setting Call : \(result)")               //
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,    // B
           bytes[1] == 0x44,    // D
           bytes[2] == 0x43 {   // C
            let result = bytes.dropFirst(3)
            print("🔥 Data result → Data Call : \(result)")               //
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,    // B
           bytes[1] == 0x54,    // T
           bytes[2] == 0x55 {   // U
            let result = bytes.dropFirst(3)
            print("🔥 Language result → Language Call : \(result)")               //
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,    // B
           bytes[1] == 0x43,    // C
           bytes[2] == 0x46 {   // F
            let result = Array(bytes.dropFirst(3))
            let part1 = String(bytes: result[0..<3], encoding: .ascii)!
            let part2 = String(bytes: result[3..<9], encoding: .ascii)!
            let part3 = String(bytes: result[9..<11], encoding: .ascii)!
            equipmentNumber = part2
//            print("🔥 Equipment Number Call result → Equipment Number Call : \(result)")
            print("🔥 Equipment Version Call result → Equipment Version Call : \(part1)")           // 장비 소프트웨어 버전
            print("🔥 Equipment S/N Number Call result → Equipment S/N Number Call : \(part2)")     // 장비 고유번호
            print("🔥 Equipment Sub Number Call result → Equipment Sub Number Call : \(part3)")     // 장비 등록번호
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x52,    // R
           bytes[1] == 0x46 {   // F
            let result = bytes.dropFirst(2)
            
            //  String 변환
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("RF result →", resultString)
                self.rf = resultString  // SwiftUI 업데이트용
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,
           bytes[1] == 0x54,
           bytes[2] == 0x49 {
            let result = bytes.dropFirst(3)
            //  String 변환
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("Product result →", resultString)
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,
           bytes[1] == 0x54,
           bytes[2] == 0x41 {
            let result = bytes.dropFirst(3)
            //  String 변환
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("Client result →", resultString)
            }
        }
        
        if bytes.count >= 3,
           bytes[0] == 0x42,
           bytes[1] == 0x54,
           bytes[2] == 0x43 {
            let result = bytes.dropFirst(3)
            //  String 변환
            let resultString = result.map { String(format: "%02X", $0) }.joined(separator: " ")
            DispatchQueue.main.async {
                print("Vehcile result →", resultString)
            }
        }
    }
}
