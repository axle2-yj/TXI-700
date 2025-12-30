//
//  AxleState.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

import Foundation

struct AxleState: Equatable {
    let axle: Int              // 1 ~ 8
    var leftWeight: Int?
    var rightWeight: Int?
    var leftBatteryLevel: Int?
    var rightBatteryLevel: Int?
    var totalWeight: Int {
        (leftWeight ?? 0) + (rightWeight ?? 0)
    }
    
    static func empty(axle: Int) -> AxleState {
        AxleState(
            axle: axle,
            leftWeight: 0,
            rightWeight: 0,
            leftBatteryLevel: 0,
            rightBatteryLevel: 0
        )
    }
}
