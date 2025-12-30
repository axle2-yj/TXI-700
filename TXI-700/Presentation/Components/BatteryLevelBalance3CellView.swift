//
//  BatteryLevelBalanceView.swift
//  TXI-700
//
//  Created by 서용준 on 12/10/25.
//

import SwiftUI
import CoreBluetooth
import Foundation

struct BatteryLevelBalance3CellView: View {
    @EnvironmentObject var bleManager: BluetoothManager
    
    @State private var blink = false
    
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
        let values = [bleManager.axles[1]?.leftWeight ?? 0,
                      bleManager.axles[1]?.rightWeight ?? 0,
                      bleManager.axles[2]?.leftWeight ?? 0,
                      bleManager.axles[2]?.rightWeight ?? 0,
                      bleManager.axles[3]?.leftWeight ?? 0,
                      bleManager.axles[3]?.rightWeight ?? 0]
        let total = (bleManager.axles[1]?.totalWeight ?? 0)
        + (bleManager.axles[2]?.totalWeight ?? 0)
        + (bleManager.axles[3]?.totalWeight ?? 0)
        let percentages: [Double] = values.map { value in
            guard total > 0 else { return 0.0 }
            return Double(value) / Double(total) * 100.0
        }
        
        if number == 7 {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: number == 7 ? 50 : 30,
                           height: number == 7 ? 50 : 30)
                    .opacity(imageName == "bat_1" && blink ? 0.2 : 1.0)
                    .onAppear {
                        if imageName == "bat_1" {
                            blink = true
                        }
                    }
                    .onDisappear {
                        blink = false
                    }
                    .animation(
                        imageName == "bat_1"
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                        value: blink
                    )
                Text(divice).font(.system(size: 30)).padding(.leading, 30).padding(.bottom, 5).lineLimit(1)
                Spacer()
                Text(String(axleWight)).font(Font.custom("TI-1700FONT", size: 30.0))
                Text("kg").font(.system(size: 30))
                Spacer()
            }.padding(20)
                .background(Color.yellow.opacity(0.8))
        } else {
            VStack(spacing: 8) {
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
                        .frame(width: number == 7 ? 50 : 30,
                               height: number == 7 ? 50 : 30)
                        .opacity(imageName == "bat_1" && blink ? 0.2 : 1.0)
                        .onAppear {
                            if imageName == "bat_1" {
                                blink = true
                            }
                        }
                        .onDisappear {
                            blink = false
                        }
                        .animation(
                            imageName == "bat_1"
                            ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                            : .default,
                            value: blink
                        )
                    Spacer()
                    if number <= percentages.count {
                        Text(String(format: "%.1f", percentages[number-1])).font(.system(size: 25))
                        Text("%").font(.system(size: 25)).lineLimit(1)
                    } else {
                        Text("0%").font(.system(size: 25))
                    }
                }
            }.padding(.horizontal, 20)
                .background(Color.yellow.opacity(0.8))
        }
    }
}
