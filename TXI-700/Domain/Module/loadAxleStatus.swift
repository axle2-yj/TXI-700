//
//  loadAxleStatus.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import Foundation

struct LoadAxleStatus: Identifiable, Codable {
    var id: Int
    var loadAxlesData: [Int] // [loadAxle1, loadAxle2, loadAxle3, loadAxle4]
    var total: Int
}
