//
//  BluetoothHandle.swift
//  TXI-700
//
//  Created by 서용준 on 1/13/26.
//

import Foundation

extension BluetoothManager: BLEEventHandling {
    
    func BluetoothHandle(_ response: BLEResponse) {
        
        DispatchQueue.main.async {
            switch response {
                
                // MARK: - ENTER / CANCEL
            case .enterOrCancel:
                self.indicatorState = .enter
                
                // MARK: - SUM / PRINT
            case .sumOrPrint:
                self.indicatorState = .sum
                
                // MARK: - MODE
            case .staticMode:
                self.updateMode(.staticMode)
                
            case .inmotionMode:
                self.updateMode(.inmotionMode)
                
            case .autoInmotionMode:
                self.updateMode(.autoInmotionMode)
                
                // MARK: - BATTERY
            case .battery(let level):
                self.indicatorBatteryLevel = level
                
                // MARK: - SERIAL
            case .serialNumber(let value):
                self.printResponse = "Print Success"
                self.SnNumber = value + 1
                
                // MARK: - INDICATOR SERIAL
            case .sirealNumberChecke(let value):
                self.IndicatorSnNumber = value
                
                // MARK: - HEADLINE
            case .headlineSaved:
                self.indicatorState = .headlineSaved
                
            case .headlineDeleted:
                self.indicatorState = .headlineDeleted
                
                // MARK: - CALL DATA
            case .itemCall(let value):
                print("itemCall \(value)")
            case .clientCall(let value):
                print("clientCall \(value)")
            case .dataCall(let value):
                print("dataCall \(value)")
            case .settingCall(let value):
                print("settingCall \(value)")
                
                // MARK: - PRINT
            case .printing:
                self.printResponse = "Print Send Success"
                self.indicatorState = .printing
                
            case .printSuccess:
                self.printResponse = "Print Success"
                self.indicatorState = .printSuccess
                
            case .printErrorCommunication:
                self.printResponse = "Print Error Communication"
                self.indicatorState = .printError(.communication)
                
            case .printErrorPaper:
                self.printResponse = "Print Error Paper"
                self.indicatorState = .printError(.noPaper)
                
                // MARK: - EQUIPMENT
            case .equipment(let value):
                self.parseEquipment(value)
                
                // MARK: - RF
            case .rf(let value):
                self.rfMassage = value
                    .map { String(format: "%02X", $0) }
                    .joined(separator: " ")
            default:
                break
            }
        }
    }
    private func updateMode(_ mode: WeightMode) {
        weightMode = mode
        modeChangeResponse = true
        modeChangeInt = mode.rawValue
        
        print("🔥 Mode Changed → \(mode)")
    }
    
    private func parseEquipment(_ value: [UInt8]) {
        guard value.count >= 11 else { return }
        let part0 = String(bytes: value[0..<5], encoding: .ascii) ?? ""
        let part1 = String(bytes: value[5..<8], encoding: .ascii) ?? ""
        let part2 = String(bytes: value[8..<14], encoding: .ascii) ?? ""
        let part3 = String(bytes: value[14..<16], encoding: .ascii) ?? ""
        
        IndicatorModelNum = part0
        equipmentVer = part1
        equipmentNumber = part2
        print("🔥 Equipment Model Num → \(part0)")
        print("🔥 Equipment Version → \(part1)")
        print("🔥 Equipment S/N → \(part2)")
        print("🔥 Equipment Sub → \(part3)")
    }
}
