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
    @Binding var seletedType : Int
    @State private var printDataByte: [UInt8] = [
        0x42, 0x54, 0x53
    ]
    @State private var printAlert: Bool = false
    @EnvironmentObject var bleManager: BluetoothManager
    
    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @ObservedObject var settingViewModel: SettingViewModel

    @Binding var printResponse: String
    
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
                        ? .black
                        : (viewModel.selectedType == nil
                            ? .white
                            : .black)
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
            print("Print Send Result: \(bleManager.sendData(printDataByte))")
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

        let delay: Double = 0.5
        let lastIndex = lines.count - 1

        for (index, line) in lines.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {

                var packet: [UInt8]

                switch index {
                case 0:
                    packet = [0x57, 0x50, 0x53] // WPS
                case lastIndex:
                    packet = [0x57, 0x50, 0x54] // WPT
                default:
                    packet = [0x57, 0x50, 0x45] // WPE
                }

                packet.append(contentsOf: line.utf8)
                packet.append(contentsOf: [0x0D, 0x0A])
                
//                print("Send[\(index)] after \(delay * Double(index))s → \(packet)")
                print("Content[\(index)] Result: \(bleManager.sendData(packet))")
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

                var packet: [UInt8]

                switch index {
                case 0:
                    packet = [0x57, 0x50, 0x53] // WPS
                case lastIndex:
                    packet = [0x57, 0x50, 0x54] // WPT
                default:
                    packet = [0x57, 0x50, 0x45] // WPE
                }

                packet.append(contentsOf: line.utf8)
                packet.append(contentsOf: [0x0D, 0x0A])

                print("Content[\(index)] Result: \(self.bleManager.sendData(packet))")
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay * Double(lines.count + 1)
        ) {
            completion()
        }
    }
}


