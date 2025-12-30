//
//  BLEEventHandler.swift
//  TXI-700
//
//  Created by 서용준 on 1/13/26.
//

protocol BLEEventHandling: AnyObject {
    func BluetoothHandle(_ response: BLEResponse)
}
