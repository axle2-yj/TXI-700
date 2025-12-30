//
//  BalanceMdoe2Cell.swift
//  TXI-700
//
//  Created by 서용준 on 1/6/26.
//

import SwiftUI

struct BalanceCellData {
    let leftWeight: Int
    let rightWeight: Int
    let leftBattery: Int
    let rightBattery: Int
}

struct BalanceModeCell: View {
    let axles: [BalanceCellData]
    let indicatorBattery: Int
    
    private var totalWeight: Int {
        axles.reduce(0) { $0 + $1.leftWeight + $1.rightWeight }
    }
    
    private var indicatorNumber: Int {
        axles.count * 2 + 1
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(axles.indices, id: \.self) { index in
                    HStack {
                        if axles.count >= 3 {
                            BatteryLevelBalance3CellView(
                                number: index * 2 + 1,
                                level: axles[index].leftBattery,
                                divice: "LEFT\(index + 1)",
                                axleWight: axles[index].leftWeight
                            )
                            
                            BatteryLevelBalance3CellView(
                                number: index * 2 + 2,
                                level: axles[index].rightBattery,
                                divice: "RIGHT\(index + 1)",
                                axleWight: axles[index].rightWeight
                            )
                        } else {
                            BatteryLevelBalanceView(
                                number: index * 2 + 1,
                                level: axles[index].leftBattery,
                                divice: "LEFT\(index + 1)",
                                axleWight: axles[index].leftWeight
                            )
                            
                            BatteryLevelBalanceView(
                                number: index * 2 + 2,
                                level: axles[index].rightBattery,
                                divice: "RIGHT\(index + 1)",
                                axleWight: axles[index].rightWeight
                            )
                        }
                    }
                }
            }.frame(height: 150)
            indicatorView
        }
    }
    
    @ViewBuilder
    private var indicatorView: some View {
        if axles.count >= 3 {
            BatteryLevelBalance3CellView(
                number: indicatorNumber,
                level: indicatorBattery,
                divice: "TOTAL",
                axleWight: totalWeight
            )
        } else {
            BatteryLevelBalanceView(
                number: indicatorNumber,
                level: indicatorBattery,
                divice: "TOTAL",
                axleWight: totalWeight
            )
        }
    }
}
