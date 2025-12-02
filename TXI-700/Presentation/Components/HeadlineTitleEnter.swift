//
//  HeadlineTitleEnter.swift
//  TXI-700
//
//  Created by 서용준 on 12/11/25.
//

import SwiftUI
import Foundation

struct HeadlineTitleEnter: View {
    let printHeadlinText: String
    @ObservedObject var viewModel: PrintFormSettingViewModel
    
    @EnvironmentObject var bleManager: BluetoothManager
    
    let DeleteByte: [UInt8] = [
        0x42, 0x54, 0x44
    ]
    
    @State private var PrintHeadlineSaveByte: [UInt8] = [
        0x42, 0x54, 0x48
    ]
    
    
    
    var body: some View {

        VStack {
            Button(action: {
                print("print HeadLine Send Result: \(bleManager.sendData(DeleteByte))")
            }) {
                Image("enter")
                    .frame(width: 10, height: 50)
                    .padding(.horizontal, 10)
            }.onReceive(bleManager.$isDelete) { _ in
                sendData()
            }
        }.onAppear {
            let asciiBytes = Array(printHeadlinText.utf8)
            PrintHeadlineSaveByte.append(contentsOf: asciiBytes)
            PrintHeadlineSaveByte.append(0x0A)
        }
    }
    
    private func sendData() {
        if bleManager.isDelete {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Print Headline change : \(bleManager.sendData(PrintHeadlineSaveByte))")
                print(printHeadlinText)
                viewModel.savePrintHeadLine(viewModel.printHeadLineText ?? "")
                
            }
        }
    }
}
