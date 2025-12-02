//
//  BLEDevice.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import Foundation
import CoreBluetooth

struct BLEDevice: Identifiable {
    var id: UUID
    var mac: String { id.uuidString }
    var name: String
    var peripheral: CBPeripheral
}
