//
//  BLEParser.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

import Foundation

struct BLEParser {
    static func parse(_ bytes: [UInt8]) -> BLEResponse {
        guard bytes.count >= 3 else {
            return .unknown(bytes)
        }
        
        switch (bytes[0], bytes[1], bytes[2]) {
        case (0x42, 0x54, 0x45): return .enterOrCancel
        case (0x42, 0x54, 0x53): return .sumOrPrint
        case (0x57, 0x4D, 0x53): return .staticMode
        case (0x57, 0x4D, 0x57): return .inmotionMode
        case (0x57, 0x4D, 0x41): return .autoInmotionMode
        case (0x53, 0x4E, _):
            let payload = bytes.dropFirst(2)
            let number = payload.reduce(0) { $0 * 10 + Int($1) }
            print(number)
            return .serialNumber(number)
        case (0x42, 0x53, 0x4E):
            let payload = Array(bytes.dropFirst(3))
            let number = payload.reduce(0) { $0 * 10 + Int($1) }
            return .sirealNumberChecke(number)
        case (0x42, 0x41, _):
            guard bytes.count >= 3 else { return .unknown(bytes) }
            let level = Int(bytes[2])
            return .battery(level: level)
        case (0x50, 0x54, 0x53): return .printSend
        case (0x50, 0x54, 0x45): return .printErrorCommunication
        case (0x50, 0x54, 0x49): return .printing
        case (0x50, 0x54, 0x50): return .printErrorPaper
        case (0x50, 0x54, 0x43): return .printSuccess
        case (0x42, 0x54, 0x44): return .headlineDeleted
        case (0x42, 0x54, 0x44): return .headlineSaved
        case (0x42, 0x54, 0x55):
            let payload = Array(bytes.dropFirst(3))
            return .language(payload)
        case (0x49, 0x54, _):
            let payload = Array(bytes.dropFirst(2))
            return .itemCall(payload)
        case (0x43, 0x4C, _):
            let payload = Array(bytes.dropFirst(2))
            return .clientCall(payload)
        case (0x42, 0x43, 0x46):
            let payload = Array(bytes.dropFirst(3))
            return .equipment(payload)
        case (0x52, 0x46, _):
            let payload = Array(bytes.dropFirst(2))
            return .rf(payload)
        case (0x42, 0x44, 0x43):
            let payload = Array(bytes.dropFirst(3))
            return .dataCall(payload)
        case (0x42, 0x53, 0x54):
            let payload = Array(bytes.dropFirst(3))
            return .settingCall(payload)
        default: return .unknown(bytes)
        }
    }
}
