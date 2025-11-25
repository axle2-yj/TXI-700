//
//  BLEDevice.swift
//  TXI-700
//
//  Created by 서용준 on 11/25/25.
//

import Foundation
import CoreBluetooth

struct BLEDevice: Identifiable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral
}
