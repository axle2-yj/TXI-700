//
//  productClientType.swift
//  TXI-700
//
//  Created by 서용준 on 12/22/25.
//

import Foundation

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
