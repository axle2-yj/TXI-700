//
//  DataSettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct PrintFormSettingScreen: View {
    @State private var isAddMode = false
    
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PrintFormSettingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
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
                                lineText("DATE".localized(languageManager.selectedLanguage) + " : " + viewModel.dateFormatter.string(from: Date()))
                            }
                            
                            if viewModel.isOn(5) {
                                lineText("TIME".localized(languageManager.selectedLanguage) + " : " + viewModel.timeFormatter.string(from: Date()))
                            }
                            
                            let product = viewModel.productTitle ?? "Item".localized(languageManager.selectedLanguage)
                            let client = viewModel.clientTitle ?? "Client".localized(languageManager.selectedLanguage)
                            if isAddMode {
                                if viewModel.isOn(6) {
                                    HStack {
                                        textFieldRow(
                                            binding: Binding(
                                                get: { product.localized(languageManager.selectedLanguage) },
                                                set: { viewModel.productTitle = $0 }
                                            )
                                        )
                                        lineText("apple".localized(languageManager.selectedLanguage))
                                        Spacer()
                                    }
                                }
                                
                                if viewModel.isOn(7) {
                                    HStack {
                                        textFieldRow(
                                            binding: Binding(
                                                get: { client.localized(languageManager.selectedLanguage) },
                                                set: { viewModel.clientTitle = $0 }
                                            )
                                        )
                                        lineText("companyname".localized(languageManager.selectedLanguage))
                                        Spacer()
                                    }
                                }
                                
                            } else {
                                if viewModel.isOn(6) {
                                    simpleRow( product.localized(languageManager.selectedLanguage) + " : ", "apple".localized(languageManager.selectedLanguage))
                                }
                                if viewModel.isOn(7) {
                                    simpleRow( client.localized(languageManager.selectedLanguage) + " : ", "companyname".localized(languageManager.selectedLanguage))
                                }
                            }
                            
                            if viewModel.isOn(8) {
                                simpleRow("S/N".localized(languageManager.selectedLanguage) + " :", "12345")
                            }
                            
                            if viewModel.isOn(9) {
                                simpleRow("Vehicle".localized(languageManager.selectedLanguage) + " :", "Vehicle")
                            }
                            
                            if viewModel.isOn(10) {
                                lineText("Line")
                            }
                            if viewModel.isOn(11) {
                                VStack(alignment: .leading) {
                                    weightRow("1Axle".localized(languageManager.selectedLanguage) + " :", "2450kg/", "2500kg")
                                    lineTextTailing("4950kg")
                                    weightRow("2Axle".localized(languageManager.selectedLanguage) + " :", "3450kg/", "3400kg")
                                    lineTextTailing("6850kg")
                                }
                            }
                            
                            if viewModel.isOn(12) {
                                VStack(alignment: .leading) {
                                    weightRow("Weight01".localized(languageManager.selectedLanguage) + " :", "2340kg", "(24.5%)")
                                    weightRow("Weight02".localized(languageManager.selectedLanguage) + " :", "2340kg", "(24.5%)")
                                    weightRow("Weight03".localized(languageManager.selectedLanguage) + " :", "2340kg", "(24.5%)")
                                    weightRow("Weight04".localized(languageManager.selectedLanguage) + " :", "2340kg", "(24.5%)")
                                }
                            }
                            
                            if viewModel.isOn(13) {
                                VStack(alignment: .leading) {
                                    simpleRow("1stWeight".localized(languageManager.selectedLanguage) + " :", "9000kg")
                                    simpleRow("2stWeight".localized(languageManager.selectedLanguage) + " :", "7000kg")
                                    simpleRow("NetWeight".localized(languageManager.selectedLanguage) + " :", "2000kg")
                                }
                            }
                            
                            lineText("Line")
                            
                            simpleRow("Total".localized(languageManager.selectedLanguage) + " : ", "9980kg")
                            
                            if viewModel.isOn(14) {
                                simpleRow("over".localized(languageManager.selectedLanguage) + " : ", "900kg")
                            }
                            
                            if viewModel.isOn(15) {
                                lineText("Line")
                            }
                            if isAddMode {
                                if viewModel.isOn(16) {
                                    HStack{
                                        Text("Inspector".localized(languageManager.selectedLanguage) + " : ")
                                        Spacer()
                                        CustomPlaceholderTextField(
                                            placeholder: "InspectorInput".localized(languageManager.selectedLanguage),
                                            text: Binding(
                                                get: {viewModel.inspectorNameText ?? ""},
                                                set: {viewModel.inspectorNameText = $0}
                                            ))
                                        Spacer()
                                    }.frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                                }
                            } else {
                                if viewModel.isOn(16) {
                                    UnderlineFieldRow("Inspector".localized(languageManager.selectedLanguage) + " : ", "", 8)
                                }
                            }
                            
                            if viewModel.isOn(17) {
                                UnderlineFieldRow("Driver".localized(languageManager.selectedLanguage) + " : ", "", 8)
                            }
                        }.padding(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .background(Color.white)
                        
                    }.background(Color.white).overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.labels.indices, id: \.self) { i in
                                HStack {
                                    Text(viewModel.labels[i].localized(languageManager.selectedLanguage))
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
            }
        }.navigationBarBackButtonHidden(true).padding()
            .onAppear {
                viewModel.loadToggles()
                viewModel.loadClientTitle()
                viewModel.loadProductTitle()
                viewModel.loadInspectorName()
            }
            .safeAreaInset(edge: .top) {
                CustomListTopBar(title: viewModel.text, onBack: {
                    viewModel.saveClientTitle(viewModel.clientTitle ?? "Clent".localized(languageManager.selectedLanguage))
                    viewModel.saveProductTitle(viewModel.productTitle ?? "Item".localized(languageManager.selectedLanguage))
                    viewModel.saveInspectorName(viewModel.inspectorNameText ?? "")
                    presentationMode.wrappedValue.dismiss()
                }, onChange: {
                    newMode in
                    isAddMode = !newMode
                    viewModel.saveClientTitle(viewModel.clientTitle ?? "Clent".localized(languageManager.selectedLanguage))
                    viewModel.saveProductTitle(viewModel.productTitle ?? "Item".localized(languageManager.selectedLanguage))
                    viewModel.saveInspectorName(viewModel.inspectorNameText ?? "")
                    print("현재 모드:", newMode ? "X" : "Add")
                })
            }
    }
}

