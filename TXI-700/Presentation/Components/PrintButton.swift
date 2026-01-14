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
    @State private var printAlert: Bool = false
    @Binding var seletedType : Int

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var bleManager: BluetoothManager
    
    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    
    @Binding var printResponse: String
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var oppositionTint: Color {
        colorScheme == .dark ? .black : .white
    }

    let lines: [String]
    var onPrint: () -> Void
    var offPrint: () -> Void
    
    var body: some View {
        VStack {
            
            Button("PRINT") {
                guard Int(bleManager.indicatorBatteryLevel ?? 0) > 2 else {
                    printAlert = true
                    return
                }
                printAlert = false
                
                if isMain {
                    printMain()
                } else {
                    startPrintWithCopies()
                }
            }.frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(
                    isMain
                    ? Color.gray.opacity(0.3)
                    : (viewModel.selectedType == nil
                       ? Color.gray.opacity(0.4)
                       : Color.gray.opacity(0.2))
                )
                .cornerRadius(6)
                .foregroundColor(
                    isMain
                    ? tint
                    : (viewModel.selectedType == nil
                       ? oppositionTint
                       : tint)
                )
        }.onReceive(bleManager.$printResponse){ newVelue in
            DispatchQueue.main.async {
                printResponse = newVelue
                if newVelue == "Print Send Success" {
                    offPrint()
                }
            }
        }.alert("", isPresented: $printAlert, actions: {
            Button("Confirmation", role: .cancel) {}
        }, message: {
            Text("batteryError1")
        })
    }
    
    func printMain() {
        if settingViewModel.weightingMethod == 0 {
            onPrint()
            bleManager.sendCommand(.bts, log: "PrintIndicator Send Result")
        } else {
            startPrintWithCopies()
        }
    }
    
    func startPrintWithCopies() {
        onPrint()
        let copies = max(1, settingViewModel.printOutputCount + 1)
        printCopies(current: 1, total: copies)
    }
    
    func printCopies(current: Int, total: Int) {
        guard current <= total else {
            offPrint()
            return
        }
        
        viewModel.printTotal = total
        viewModel.printingNumber = current
        
        switch seletedType {
        case 0:
            printLineData(lines: lines) {
                self.printCopies(current: current + 1, total: total)
            }
            
        case 1:
            printLoadAxleInfos(infos: viewModel.todayLoadAxleItems) {
                self.printCopies(current: current + 1, total: total)
            }
            
        case 2:
            printLoadAxleInfos(infos: viewModel.loadAxleItems) {
                self.printCopies(current: current + 1, total: total)
            }
            
        default:
            offPrint()
        }
    }
    
    func printLineData(
        lines: [String],
        completion: @escaping () -> Void
    ) {
        guard !lines.isEmpty else {
            completion()
            return
        }
        
        let delay: Double = 0.6
        let lastIndex = lines.count - 1
        
        for (index, line) in lines.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                
                switch index {
                case 0: bleManager.sendCommand(.wps(line), log: "PrintOneLine Start Send Result")
                case lastIndex: bleManager.sendCommand(.wpt(line), log: "PrintOneLine Last Send Result")
                default: bleManager.sendCommand(.wpe(line), log: "PrintOneLine Send Result")
                }
                
                //                print("Send[\(index)] after \(delay * Double(index))s → \(packet)")
                //                print("Content[\(index)] Result: \(bleManager.sendData(packet))")
            }
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay * Double(lines.count + 1)
        ) {
            completion()
        }
    }
    
    // MARK: - 연속 출력 데이터 묶음 나눔    
    func printLoadAxleInfos(
        infos: [LoadAxleInfo],
        completion: @escaping () -> Void
    ) {
        guard !infos.isEmpty else {
            completion()
            return
        }
        
        viewModel.printTotal = infos.count
        sendNext(index: 0, infos: infos, completion: completion)
    }
    
    private func sendNext(
        index: Int,
        infos: [LoadAxleInfo],
        completion: @escaping () -> Void
    ) {
        guard index < infos.count else {
            completion()
            return
        }
        
        viewModel.printingNumber = index + 1
        
        let info = infos[index]
        let lines = PrintLineBuilder.buildLines(
            info: info,
            dataViewModel: viewModel,
            printViewModel: printViewModel
        )
        
        sendLines(lines) {
            self.sendNext(index: index + 1, infos: infos, completion: completion)
        }
    }
    
    func sendLines(
        _ lines: [String],
        completion: @escaping () -> Void
    ) {
        let delay: Double = 0.5
        let lastIndex = lines.count - 1
        
        for (index, line) in lines.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                switch index {
                    
                case 0: bleManager.sendCommand(.wps(line), log: "PrintOneLine Start Send Result")
                case lastIndex: bleManager.sendCommand(.wpt(line), log: "PrintOneLine Last Send Result")
                default: bleManager.sendCommand(.wpe(line), log: "PrintOneLine Send Result")
                }
                //                print("Content[\(index)] Result: \(self.bleManager.sendData(packet))")
            }
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay * Double(lines.count + 1)
        ) {
            completion()
        }
    }
}


