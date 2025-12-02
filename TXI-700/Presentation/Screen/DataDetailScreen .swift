//
//  DataDetailScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct DataDetailScreen: View {
    @State var currentIndex: Int
    @State var loadAxleItem: LoadAxleInfo

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    
    var body: some View {
        VStack(spacing : 0) {
            CustomTopBar(title: viewModel.dataDatilTitle, onBack: {
                presentationMode.wrappedValue.dismiss()
            })
            VStack {
                if printViewModel.isOn(0) {
                    lineText("Line")
                }
                
                if printViewModel.isOn(1) {
                    lineText(printViewModel.printHeadLineText ?? "Print Head Line")
                }
                
                if printViewModel.isOn(2) {
                    lineText("Line")
                }
                
                if printViewModel.isOn(3) {
                    lineText(loadAxleItem.timestamp.map { printViewModel.frmatter.string(from: $0) } ?? "N/A")
                }
                
                if printViewModel.isOn(4) {
                    lineText("DATE : " + (loadAxleItem.timestamp.map { printViewModel.dateFormatter.string(from: $0) } ?? "N/A"))
                }
                
                if printViewModel.isOn(5) {
                    lineText("TIME : " + (loadAxleItem.timestamp.map { printViewModel.timeFormatter.string(from: $0) } ?? "N/A"))
                }
                                
                if printViewModel.isOn(6) {
                    simpleRow((viewModel.productTitle ?? "Item") + " : ", loadAxleItem.product ?? "N/A")
                }
                if printViewModel.isOn(7) {
                    simpleRow((viewModel.clientTitle ?? "Client") + " : ", loadAxleItem.client ?? "N/A")
                }
                
                if printViewModel.isOn(8) {
                    simpleRow("S/N :", loadAxleItem.serialNumber ?? "N/A")
                }
                
                if printViewModel.isOn(9) {
                    simpleRow("Vehicle :", loadAxleItem.vehicle ?? "N/A")
                }
                
                if printViewModel.isOn(10) {
                    lineText("Line")
                }
                // Load Axles 출력
                if let data = loadAxleItem.loadAxleData,
                   let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
                    let rowCount = (loadAxles.count + 1) / 2  // 2개씩 묶어 몇 줄 필요한지
                    let firstWight = (loadAxles[0] + loadAxles[1])
                    let secondWight = (loadAxles[2] + loadAxles[3])
                    let totalSum = loadAxles.reduce(0, +)

                    ForEach(0..<rowCount, id: \.self) { rowIndex in
                        let firstIndex = rowIndex * 2
                        let secondIndex = firstIndex + 1
                        
                        let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
                        let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0
                        
                        let firstPercent = totalSum > 0 ? (Double(firstValue) / Double(totalSum)) * 100 : 0
                        let secondPercent = totalSum > 0 ? (Double(secondValue) / Double(totalSum)) * 100 : 0

                        if printViewModel.isOn(11) {
                            VStack(alignment: .leading) {
                                weightRow("\(rowIndex + 1)Axle :", "\(firstValue)kg/", "\(secondValue)kg")
                                lineText("\(firstValue + secondValue)kg")
                            }
                        }
                        
                        if printViewModel.isOn(12) {
                            VStack(alignment: .leading) {
                                weightRow("Weight\(rowIndex+1) :", "\(firstValue)kg", "(\(String(format: "%.1f", firstPercent))%)")
                                weightRow("Weight\(rowIndex+2) :", "\(secondValue)kg", "(\(String(format: "%.1f", secondPercent))%)")
                            }
                        }
                    }
                    
                    if printViewModel.isOn(13) {
                        VStack(alignment: .leading) {
                            simpleRow("1st Weight :", String(firstWight))
                            simpleRow("2st Weight :", String(secondWight))
                            simpleRow("Net Weight :", String(firstWight - secondWight))
                        }
                        
                    }
                    lineText("Line")
                    
                    simpleRow("Total :", String(totalSum))
                    
                    if printViewModel.isOn(14) {
                        simpleRow("over :", String(firstWight - secondWight))
                    }
                }

                
                if printViewModel.isOn(15) {
                    lineText("Line")
                }
                
                if printViewModel.isOn(16) {
                    UnderlineFieldRow("Inspector : ", printViewModel.inspectorNameText ?? "", 8)
                }
                
                
                if printViewModel.isOn(17) {
                    UnderlineFieldRow("Driver : ", "", 8)
                }
            }
            .padding(10)
            .frame(maxWidth: 240, alignment: .top)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Text(String(currentIndex + 1))
                Text(" / " + String(viewModel.loadAxleItems.count))
                
                Button(action: {
                    if currentIndex > 0 {
                                currentIndex -= 1
                                loadAxleItem = viewModel.loadAxleItems[currentIndex]
                            }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                }
                
                Button(action: {
                    if currentIndex < viewModel.loadAxleItems.count - 1 {
                                currentIndex += 1
                                loadAxleItem = viewModel.loadAxleItems[currentIndex]
                            }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                }
            }
            Spacer()
        }.navigationBarBackButtonHidden(true)
    }
}
