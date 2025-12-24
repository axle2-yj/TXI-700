//
//  SettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct SettingScreen: View {
    @State private var goToPrintFormSetting = false
    @State var toggles = Array(repeating: false, count: 17)
    @State private var optionProduct = true
    @State private var optionClient = true
    @State private var selectedProduct: ProductInfo? = nil
    @State private var selectedClient: ClientInfo? = nil

    @ObservedObject var viewModel: SettingViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var bleManager: BluetoothManager

    var body: some View {
        VStack(spacing : 0) {
            CustomTopBar(title: viewModel.title, onBack: {
                presentationMode.wrappedValue.dismiss()
            })
            VStack {
                HStack {
                    VStack(spacing: 8) {
                        SettingLineText("Lenguge")
                        HStack {
                            segmentButton(title: "English", tag: 0)
                            segmentButton(title: "Japanese", tag: 1)
                            segmentButton(title: "Korean", tag: 2)
                        }
                        .frame(height: 36)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                    }.padding()
                }.frame(maxWidth: .infinity)
                    .padding()
                
                HStack {
                    VStack(spacing: 8) {
                        SettingLineText("ModeChange")
                        Button(String(viewModel.modeName)) {
                            viewModel.disableButton()
                            switch viewModel.modeInt {
                            case 0:
                                viewModel.saveModeChange(1)
                                bleManager.sendInitialModeChangeCommand()
                            case 1:
                                viewModel.saveModeChange(2)
                                bleManager.sendInitialModeChangeCommand()
                            case 2:
                                viewModel.saveModeChange(0)
                                bleManager.sendInitialModeChangeCommand()
                            default :
                                break
                            }
                        }.padding()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                            .disabled(viewModel.isModeButtonDisabled)
                            .onReceive(bleManager.$modeChangeResponse) { success in
                                if success {
                                    viewModel.enableButton()   // 다시 눌릴 수 있게 활성화
                                    bleManager.modeChangeResponse = false      // 응답 플래그 초기화
                                }
                            }
                    }.frame(maxWidth: .infinity)
                        .padding()
                    VStack(spacing: 8) {
                        SettingLineText("PrintForm")
                        Button("Edit") {
                            goToPrintFormSetting = true
                        }.navigationDestination(isPresented: $goToPrintFormSetting){
                            PrintFormSettingScreen(viewModel: printViewModel)
                        }.padding()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                    }.frame(maxWidth: .infinity)
                        .padding()
                }
                
                VStack(spacing: 8) {
                    SettingLineText("PrintHeadline")
                    HStack {
                        TextField("PrintHeadLineText", text: Binding(
                                get: {printViewModel.printHeadLineText ?? "Print HeadLine Text"},
                                set: {printViewModel.printHeadLineText = $0}
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                        HeadlineTitleEnter(printHeadlinText: printViewModel.printHeadLineText ?? "",viewModel: printViewModel)
                    }
                }
                
                VStack(spacing: 8) {
                    SettingLineText("ActivateButton")
                    HStack {
                        if viewModel.weightingMethod == 0 {
                            CheckBox(isChecked: $optionProduct,
                                     viewModel: viewModel,
                                     label: "\(selectedProduct?.name ?? viewModel.saveProduct ?? "ITEM")",
                                     select: "product")
                                                .disabled(true).opacity(0.6)
                            CheckBox(isChecked: $optionClient,
                                     viewModel: viewModel,
                                     label: "\(selectedClient?.name ?? viewModel.saveClient ?? "CLIENT")",
                                     select: "client")
                                                .disabled(true).opacity(0.6)
                        } else {
                            CheckBox(isChecked: $optionProduct,
                                     viewModel: viewModel,
                                     label: "\(selectedProduct?.name ?? viewModel.saveProduct ?? "ITEM")",
                                     select: "product")
                            CheckBox(isChecked: $optionClient,
                                     viewModel: viewModel,
                                     label: "\(selectedClient?.name ?? viewModel.saveClient ?? "CLIENT")",
                                     select: "client")
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(spacing: 8)  {
                    SettingLineText("WeightingMathod")
                    HStack {
                        weightingMathodSegmentButton(title: "Indicator", tag: 0)
                        weightingMathodSegmentButton(title: "One-Time", tag: 1)
                        weightingMathodSegmentButton(title: "Two-step", tag: 2)
//                        weightingMathodSegmentButton(title: "Blance", tag: 3)
                    }
                    .frame(height: 36)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                
                VStack(spacing: 8)  {
                    SettingLineText("PrintOutputSetting")
                    HStack {
                        printOutputSettingSegmentButton(title: "One", tag: 0)
                        printOutputSettingSegmentButton(title: "Two", tag: 1)
                        printOutputSettingSegmentButton(title: "Three", tag: 2)
                    }.frame(height: 36)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
            }.navigationBarBackButtonHidden(true).padding()
        }.onAppear {
            viewModel.loadProduct()
            viewModel.loadClient()
            viewModel.loadModeChange()
            viewModel.loadClientCkeck()
            viewModel.loadProductCkeck()
            viewModel.loadLanguage()
            viewModel.loadWeightingMethod()
            printViewModel.loadPrintHeadLine()
            DispatchQueue.main.async {
                optionProduct = viewModel.checkedProduct
                optionClient = viewModel.checkedClient
            }
        }.safeAreaInset(edge: .bottom, alignment: .center) {
            HStack {
                Text("Indecator Ver. : \(bleManager.equipmentVer)").opacity(0.4)
            }
        }
    }
}

// MARK: - SEGMENT BUTTON

extension SettingScreen {
    func segmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.toggleChanged(to: tag)
            bleManager.sendLangugeCommand(lang: tag)
            viewModel.saveLanguage(tag)
            switch tag {
            case 0: languageManager.changeLanguage(to: "en")
            case 1: languageManager.changeLanguage(to: "ja")
            case 2: languageManager.changeLanguage(to: "ko")
            default:languageManager.changeLanguage(to: "en")
            }
        }) {
            Text(title.localized(languageManager.selectedLanguage))
                .frame(maxWidth: .infinity)
                .background(viewModel.language == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}

// MARK: - SEGMENT BUTTON

extension SettingScreen {
    func weightingMathodSegmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.weightToggleChanged(to: tag)
            viewModel.saveWeightingMethod(tag)
            if tag == 0 {
               optionProduct = true
               optionClient = true
            }
        }) {
            Text(title.localized(languageManager.selectedLanguage))
                .frame(maxWidth: .infinity)
                .background(viewModel.weightingMethod == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}

// MARK: - SEGMENT BUTTON

extension SettingScreen {
    func printOutputSettingSegmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.printOutputToggleChanged(to: tag)
            viewModel.savePrintOutputCountSetting(tag)
        }) {
            Text(title.localized(languageManager.selectedLanguage))
                .frame(maxWidth: .infinity)
                .background(viewModel.printOutputCount == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}
