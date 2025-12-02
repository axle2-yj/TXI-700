//
//  BatteryLevelLoadAxleWeightView.swift
//  TXI-700
//
//  Created by 서용준 on 12/10/25.
//

import SwiftUI
import CoreBluetooth
import Foundation

struct BatteryLevelLoadAxleWeightView: View {
    let level: Int  // 0~5 값
    let divice: String // LEFT, RIGHT, AXLE
    let axleWight: String
        var imageName: String {
            if divice == "AXLE:" {
                switch level/2 {
                case 0: return "bat_1"
                case 1: return "bat_2"
                case 2: return "bat_3"
                case 3: return "bat_4"
                case 4...: return "bat_5"
                default: return "bat_1"
                }
            } else {
                switch level {
                case 0: return "bat_1"
                case 1: return "bat_2"
                case 2: return "bat_3"
                case 3: return "bat_4"
                case 4...: return "bat_5"
                default: return "bat_1"
                }
            }
        }
    var body: some View {
        HStack {
            switch divice {
            case "LEFT:": Text("1")
            case "RIGHT:": Text("2")
            case "AXLE:": Text("  ")
            default: Text("  ")
            }
            Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
            Text(divice).font(.system(size: 25)).padding(.leading, 30).padding(.bottom, 5)
            Spacer()
            Text(axleWight).font(Font.custom("TI-1700FONT", size: 25.0))
            Text("kg").font(.system(size: 25))
        }.padding(.horizontal, 20).background(Color.yellow)

    }
}
