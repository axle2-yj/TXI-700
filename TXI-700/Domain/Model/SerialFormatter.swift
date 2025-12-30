//
//  SerialFormatter.swift
//  TXI-700
//
//  Created by 서용준 on 1/12/26.
//

import Foundation

enum SerialFormatter {
    static func format(_ value: Int) -> String {
        String(format: "%05d", value)
    }
}
