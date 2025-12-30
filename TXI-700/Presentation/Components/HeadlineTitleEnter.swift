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
                bleManager.sendPrintHeadLineDeleteCommand()
            }) {
                Image("enter")
                    .frame(width: 10, height: 50)
                    .padding(.horizontal, 10)
            }.onReceive(bleManager.$isDelete) { _ in
                sendHeadline()
            }
        }
    }
    
    private func sendHeadline() {
        guard bleManager.isDelete else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            bleManager.sendPrintHeadLineCommand(title: printHeadlinText)
            viewModel.savePrintHeadLine(viewModel.printHeadLineText ?? "")
        }
    }
}
