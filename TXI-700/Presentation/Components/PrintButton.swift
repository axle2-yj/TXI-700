//
//  PrintButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/1/25.
//

import SwiftUI
import Foundation

struct PrintButton: View {
    @State var isMain = false
    @State var seletedType = 0
    @EnvironmentObject var bleManager: BluetoothManager
    @ObservedObject var viewModel: DataViewModel
    @Binding var printResponse: String
    let lines: [String]
    
    @State private var printDataByte: [UInt8] = [
        0x42, 0x54, 0x53
    ]
    
    var body: some View {
        let isDisabled = (!isMain && viewModel.selectedType == nil)
                
        VStack {
            Button("PRINT") {
                if isMain {
                    print("Print Send Result: \(bleManager.sendData(printDataByte))")
                } else {
                    if lines.isEmpty { return }
                    for line in lines {
                                var packet: [UInt8] = [0x42, 0x54, 0x53]
                                let ascii = Array(line.utf8)
                                packet.append(contentsOf: ascii)
                                packet.append(0x0A)   // 줄바꿈

                                print("Packet Send: \(packet)")
                                print("Print Send Result: \(bleManager.sendData(packet))")
                            }
                    print("seletedType: \(seletedType)")
                }
            }.frame(maxWidth: .infinity)
                .padding()
                .background(
                    isDisabled
                    ? Color.gray.opacity(0.4)
                    : Color.gray.opacity(0.2)
                )
                .cornerRadius(6)
                .foregroundColor(
                    isDisabled
                    ? .white
                    : .black
                )
                .disabled(isDisabled)
        }.onReceive(bleManager.$printResponse){ newVelue in
            printResponse = newVelue
        }
    }
}
