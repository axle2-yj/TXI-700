//
//  productClientType.swift
//  TXI-700
//
//  Created by 서용준 on 12/22/25.
//

import Foundation

enum BLEItemType {
    case product
    case client
    case vechicle
}

extension String {
    func toAsciiBytes(maxLength: Int) -> [UInt8] {
        return Array(self.utf8.prefix(maxLength))
    }
}

func numTo2ByteAscii(_ num: Int) -> [UInt8] {
    let clamped = max(0, min(num, 99))
    let str = String(format: "%02d", clamped)
    return Array(str.utf8)   // 항상 2바이트
}

func numToByte(_ num: Int) -> UInt8 {
    return UInt8(max(0, min(num, 99)))
}

func makePacket(
    type: BLEItemType,
    num: Int,
    name: String,
) -> [UInt8] {

    // Header 정의
    let header: [UInt8]
    switch type {
    case .product:
        header = [0x42, 0x54, 0x49] // "BTI"
    case .client:
        header = [0x42, 0x54, 0x41] // "BTA"
    case .vechicle:
        header = [0x42, 0x54, 0x43] // "BTC"
    }
    if type == .vechicle {
        let nameBytes = name.toAsciiBytes(maxLength: 10)
        let packet = header + nameBytes + [0x0A]
        return packet
    } else {
        let numByte = numTo2ByteAscii(num)
        let nameBytes = name.toAsciiBytes(maxLength: 20)
        let packet = header + numByte + nameBytes + [0x0A]
        return packet
    }
}
