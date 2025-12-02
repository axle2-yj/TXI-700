//
//  DataSettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct PrintFormSettingScreen: View {
    @State private var isAddMode = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PrintFormSettingViewModel

    var body: some View {
        VStack(spacing: 0) {
            CustomListTopBar(title: viewModel.text, onBack: {
                viewModel.saveClientTitle(viewModel.clientTitle ?? "Clent")
                viewModel.saveProductTitle(viewModel.productTitle ?? "Item")
                viewModel.saveInspectorName(viewModel.inspectorNameText ?? "")
                presentationMode.wrappedValue.dismiss()
            }, onChange: {
                newMode in
                isAddMode = !newMode
                viewModel.saveClientTitle(viewModel.clientTitle ?? "Clent")
                viewModel.saveProductTitle(viewModel.productTitle ?? "Item")
                viewModel.saveInspectorName(viewModel.inspectorNameText ?? "")
                print("현재 모드:", newMode ? "X" : "Add")
            })
            HStack {
                VStack {
                    VStack(spacing: 0) {
                        if viewModel.isOn(0) {
                            lineText("Line")
                        }
                        
                        if viewModel.isOn(1) {
                            lineText(viewModel.printHeadLineText ?? "Print Head Line")
                        }
                        
                        if viewModel.isOn(2) {
                            lineText("Line")
                        }
                        
                        if viewModel.isOn(3) {
                            lineText(viewModel.frmatter.string(from: Date()))
                        }
                        
                        if viewModel.isOn(4) {
                            lineText("DATE : " + viewModel.dateFormatter.string(from: Date()))
                        }
                        
                        if viewModel.isOn(5) {
                            lineText("TIME : " + viewModel.timeFormatter.string(from: Date()))
                        }
                        
                        if isAddMode {
                            if viewModel.isOn(6) {
                                HStack {
                                    textFieldRow(
                                        binding: Binding(
                                            get: { viewModel.productTitle ?? "Item" },
                                            set: { viewModel.productTitle = $0 }
                                        )
                                    )
                                    lineText("apple")
                                    Spacer()
                                }
                            }
                            
                            if viewModel.isOn(7) {
                                HStack {
                                    textFieldRow(
                                        binding: Binding(
                                            get: { viewModel.clientTitle ?? "Client" },
                                            set: { viewModel.clientTitle = $0 }
                                        )
                                    )
                                    lineText("company")
                                    Spacer()
                                }
                            }
                            
                        } else {
                            if viewModel.isOn(6) {
                                simpleRow((viewModel.productTitle ?? "Item") + " : ", "apple")
                            }
                            if viewModel.isOn(7) {
                                simpleRow((viewModel.clientTitle ?? "Client") + " : ", "company")
                            }
                        }
                        
                        if viewModel.isOn(8) {
                            simpleRow("S/N :", "P12345")
                        }
                        
                        if viewModel.isOn(9) {
                            simpleRow("Vehicle :", "Vehicle")
                        }
                        
                        if viewModel.isOn(10) {
                            lineText("Line")
                        }
                        if viewModel.isOn(11) {
                            VStack(alignment: .leading) {
                                weightRow("1Axle :", "2450kg/", "2500kg")
                                lineText("4950kg")
                                weightRow("2Axle :", "3450kg/", "3400kg")
                                lineText("6850kg")
                            }
                        }
                        
                        if viewModel.isOn(12) {
                            VStack(alignment: .leading) {
                                weightRow("Weight01 :", "2340kg", "(24.5%)")
                                weightRow("Weight02 :", "2340kg", "(24.5%)")
                                weightRow("Weight03 :", "2340kg", "(24.5%)")
                                weightRow("Weight04 :", "2340kg", "(24.5%)")
                            }
                        }
                        
                        if viewModel.isOn(13) {
                            VStack(alignment: .leading) {
                                simpleRow("1st Weight :", "9000kg")
                                simpleRow("2st Weight :", "7000kg")
                                simpleRow("Net Weight :", "2000kg")
                            }
                        }
                        
                        lineText("Line")
                        
                        simpleRow("Total :", "9980kg")
                        
                        if viewModel.isOn(14) {
                            simpleRow("over :", "900kg")
                        }
                        
                        if viewModel.isOn(15) {
                            lineText("Line")
                        }
                        if isAddMode {
                            if viewModel.isOn(16) {
                                HStack{
                                    Text("Inspector : ")
                                    Spacer()
                                    TextField("", text: Binding(
                                            get: {viewModel.inspectorNameText ?? ""},
                                            set: {viewModel.inspectorNameText = $0}
                                        )
                                    )
                                    Spacer()
                                }.frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                            }
                        } else {
                            if viewModel.isOn(16) {
                                UnderlineFieldRow("Inspector : ", "", 8)
                            }
                        }
                        
                        if viewModel.isOn(17) {
                            UnderlineFieldRow("Driver : ", "", 8)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }.background(Color.white)
                
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        ForEach(viewModel.labels.indices, id: \.self) { i in
                            HStack {
                                Text(viewModel.labels[i])
                                Spacer()
                                
                                if isAddMode {
                                    Toggle(
                                        "",
                                        isOn: Binding(
                                            get: { viewModel.toggles[i]},
                                            set: { newValue in
                                                viewModel.toggleChanged(index: i, value: newValue)
                                            }
                                        )
                                    )
                                    .labelsHidden()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                }
            }
        }.navigationBarBackButtonHidden(true).padding()
            .onAppear {
                viewModel.loadToggles()
                viewModel.loadClientTitle()
                viewModel.loadProductTitle()
                viewModel.loadInspectorName()
            }
    }
}

