//
//  BLEChunkSender.swift
//  TXI-700
//
//  Created by 서용준 on 1/12/26.
//

import CoreBluetooth

enum BLEChunkSender {
    
    static let mtu = 180
    
    static func sendJSON(
        _ data: Data,
        peripheral: CBPeripheral,
        characteristic: CBCharacteristic
    ) {
        let bytes = [UInt8](data)
        var index = 0
        
        while index < bytes.count {
            let chunkSize = min(mtu, bytes.count - index)
            let chunk = Data(bytes[index..<index + chunkSize])
            
            peripheral.writeValue(
                chunk,
                for: characteristic,
                type: .withResponse
            )
            
            index += chunkSize
        }
    }
}
