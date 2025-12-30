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
    
    var body: some View {
        
        VStack {
            Button(action: {
                bleManager.sendCommand(.btd, log: "PrintHeadLineDelete send Result")
                sendHeadline()
            }) {
                Image("enter")
                    .frame(width: 10, height: 50)
                    .padding(.horizontal, 10)
            }
//            .onReceive(bleManager.$isDelete) { _ in
//                sendHeadline()
//            }
        }
    }
    
    private func sendHeadline() {
//        guard bleManager.isDelete else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //            bleManager.sendPrintHeadLineCommand(title: printHeadlinText)
            bleManager.sendCommand(.bth(printHeadlinText), log: "PrintHeadLine Send Result")
            viewModel.savePrintHeadLine(viewModel.printHeadLineText ?? "")
            bleManager.indicatorState = .idle
        }
    }
}
