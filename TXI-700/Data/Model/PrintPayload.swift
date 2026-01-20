//
//  PrintPayload.swift
//  TXI-700
//
//  Created by 서용준 on 1/12/26.
//

import Foundation

struct PrintPayload: Codable {
    let printHeadLine: String
    let date: String
    let item: String
    let client: String
    let serialNumber: String
    let vehicleNumber: String
    let equipmentNumber: String
    let equipmentSubNum: String // 장비 서브번호
    let loadAxle: [Int]
    let weight: String         // 0, 1, 2, 3
    let total: String
    let inspector: String
}

struct PrintPayloadWrapper: Codable {
    let list: [PrintPayload]
}
