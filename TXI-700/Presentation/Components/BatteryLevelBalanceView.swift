//
//  BatteryLevelBalanceView.swift
//  TXI-700
//
//  Created by 서용준 on 12/10/25.
//

import SwiftUI
import CoreBluetooth
import Foundation

struct BatteryLevelBalanceView: View {
    @EnvironmentObject var bleManager: BluetoothManager
    
    let number: Int
    let level: Int  // 0~5 값
    let divice: String // LEFT1, RIGHT1, LEFT2, RIGHT2, TOTAL
    let axleWight: Int
        var imageName: String {
            if divice == "TOTAL" {
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
        let values = [bleManager.leftLoadAxel1 ?? 0, bleManager.rightLoadAxel1 ?? 0, bleManager.leftLoadAxel2 ?? 0, bleManager.rightLoadAxel2 ?? 0]
        let total = values.reduce(0, +)
        let percentages: [Double] = values.map { value in
            guard total > 0 else { return 0.0 }
            return Double(value) / Double(total) * 100.0
        }
        
        if number == 5 {
            HStack {
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text(divice).font(.system(size: 30)).padding(.leading, 30).padding(.bottom, 5)
                Spacer()
                Text(String(axleWight)).font(Font.custom("TI-1700FONT", size: 30.0))
                Text("kg").font(.system(size: 30))
                Spacer()
            }.padding(20).background(Color.yellow)
        } else {
            VStack {
                HStack {
                    Text(String(number)).font(.title2)
                    Spacer()
                    Text(String(axleWight)).font(Font.custom("TI-1700FONT", size: 25.0))
                    Text("kg").font(.system(size: 25))
                }
                HStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .leading)
                    if number < percentages.count {
                        Text(String(format: "%.1f", percentages[number-1])).font(.system(size: 25))
                        Text("%").font(.system(size: 25))
                    } else {
                        Text("0%").font(.system(size: 25))
                    }
                }
            }.padding(.horizontal, 20).background(Color.yellow)
        }
    }
}
