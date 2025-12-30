//
//  SettingScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI

struct SettingScreen: View {
    @State private var goToPrintFormSetting = false
    @State private var optionProduct = true
    @State private var optionClient = true
    @State private var selectedProduct: ProductInfo? = nil
    @State private var selectedClient: ClientInfo? = nil
    @State private var dangerousText: String = ""
    @State private var cautionText: String = ""
    @State private var safetyText: String = ""

    @ObservedObject var viewModel: SettingViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var bleManager: BluetoothManager

    var body: some View {
        VStack {
            ScrollView {
                // 언어 설정
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
                        
                    }
                }.padding()
                .frame(maxWidth: .infinity)
                .background(Image("box_2")
                    .resizable()
                    .scaledToFill()
                )
//                .background(Color.blue.opacity(0.1)) // <- 여기서 하늘색 배경 적용
//                .cornerRadius(8)
                // 모드 선택 및 프린트 양식 설정 이동 버튼
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
                                    viewModel.enableButton()
                                    bleManager.modeChangeResponse = false
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
                }.background(Image("box_3")
                    .resizable()
                    .scaledToFill()
                )
                // Print 양식 해드라인
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
                }.padding()
                    .background(Image("box_2")
                        .resizable()
                        .scaledToFill()
                    )
                // 버튼 활성화 여부
                VStack(spacing: 8) {
                    SettingLineText("ActivateButton")
                    HStack {
                        if viewModel.weightingMethod == 0 {
                            CheckBox(isChecked: $optionProduct,
                                     viewModel: viewModel,
                                     label: "\(selectedProduct?.name ?? viewModel.saveProduct ?? "ITEM")",
                                     select: "product")
                                                .disabled(true).opacity(0.6)
                                                .onAppear {
                                                    viewModel.saveProductCkeck(optionProduct)
                                                }
                            CheckBox(isChecked: $optionClient,
                                     viewModel: viewModel,
                                     label: "\(selectedClient?.name ?? viewModel.saveClient ?? "CLIENT")",
                                     select: "client")
                                                .disabled(true).opacity(0.6)
                                                .onAppear {
                                                    viewModel.saveClientCkeck(optionClient)
                                                }
                           
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
                }.padding()
                    .background(Image("box_1")
                        .resizable()
                        .scaledToFill()
                    )
                
                // 가중치 부여 방법 및 우선순위
                VStack(spacing: 8)  {
                    SettingLineText("WeightingMathod")
                    HStack {
                        weightingMathodSegmentButton(title: "Indicator", tag: 0)
                        weightingMathodSegmentButton(title: "One-Time", tag: 1)
                        weightingMathodSegmentButton(title: "Two-step", tag: 2)
                        weightingMathodSegmentButton(title: "Balance", tag: 3)
                    }
                    .frame(height: 36)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }.padding()
                    .background(Image("box_2")
                        .resizable()
                        .scaledToFill()
                    )
                
                // Print 출력 숫자 설정
                VStack(spacing: 8) {
                    SettingLineText("PrintOutputSetting")
                    HStack {
                        printOutputSettingSegmentButton(title: "One", tag: 0)
                        printOutputSettingSegmentButton(title: "Two", tag: 1)
                        printOutputSettingSegmentButton(title: "Three", tag: 2)
                    }.frame(height: 36)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }.padding()
                    .background(Image("box_2")
                        .resizable()
                        .scaledToFill()
                    )
                
                // 축 수 설정
                if viewModel.weightingMethod == 3 {
                    VStack(spacing: 8) {
                        SettingLineText("BalanceAxisNumberSetting")
                        HStack {
                            balanceAxisNumberSettingSagmentButton(title: "number4", tag: 0)
                            balanceAxisNumberSettingSagmentButton(title: "number6", tag: 1)
//                            balanceAxisNumberSettingSagmentButton(title: "number8", tag: 2)
                        }.frame(height: 36)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }.padding()
                        .background(Image("box_2")
                            .resizable()
                            .scaledToFill()
                        )
                    
                    // 수직/수평 합계및 가중치 설정
                    VStack(spacing: 8) {
                        SettingLineText("BlanceWeightSetting")
                        HStack {
                            balanceWeightSagmentButton(title: "Invisible", tag: 0)
                            balanceWeightSagmentButton(title: "Visible", tag: 1)
                        }
                    }.padding()
                        .background(Image("box_2")
                            .resizable()
                            .scaledToFill()
                        )
                    
                    VStack(spacing: 8) {
                        SettingLineText("balanceValueSetting")
                        PercentInputRow(
                            title: "dangerousValueSetting".localized(languageManager.selectedLanguage),
                            text: $dangerousText) { number in
                            viewModel.saveDangerousNumberSetting(number)
                        }
                        PercentInputRow(
                            title: "cautionValueSetting".localized(languageManager.selectedLanguage),
                            text: $cautionText) { number in
                            viewModel.saveCautionNumberSetting(number)
                        }
                        PercentInputRow(
                            title: "safetyValueSetting".localized(languageManager.selectedLanguage),
                            text: $safetyText) { number in
                            viewModel.saveSafetyNumberSetting(number)
                        }
                    }.padding()
                        .background(Image("box_2")
                            .resizable()
                            .scaledToFill()
                        )
                }
                Spacer()
                HStack {
                    Text("Indecator Ver. : \(bleManager.equipmentVer)").opacity(0.4)
                }
            }.navigationBarBackButtonHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }.onAppear {
            viewModel.loadProduct()
            viewModel.loadClient()
            viewModel.loadModeChange()
            viewModel.loadClientCkeck()
            viewModel.loadProductCkeck()
            viewModel.loadLanguage()
            viewModel.loadWeightingMethod()
            viewModel.loadDangerousNumberSetting()
            viewModel.loadCautionNumberSetting()
            viewModel.loadSafetyNumberSetting()
            printViewModel.loadPrintHeadLine()
            DispatchQueue.main.async {
                optionProduct = viewModel.checkedProduct
                optionClient = viewModel.checkedClient
            }
            dangerousText = String(viewModel.dangerous)
            cautionText = String(viewModel.caution)
            safetyText = String(viewModel.safety)
        }.safeAreaInset(edge: .top) {
            CustomTopBar(title: viewModel.title, onBack: {
                hideKeyboard()
                presentationMode.wrappedValue.dismiss()
            })
        }
//        .safeAreaInset(edge: .bottom, alignment: .center) {
//            HStack {
//                Text("Indecator Ver. : \(bleManager.equipmentVer)").opacity(0.4)
//            }
//        }
    }
}

// MARK: - LENGUAGE SEGMENT BUTTON

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

// MARK: - WIGHTING MATHOD SEGMENT BUTTON

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

// MARK: - PRINT OUTPUT SEGMENT BUTTON

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

// MARK: - BALANCE AXIS NUMBER SEGMENT BUTTON

extension SettingScreen {
    func balanceAxisNumberSettingSagmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.balanceAxisNumberToggleChanged(to: tag)
            viewModel.saveBalanceAxisNumberSetting(tag)
        }) {
            Text(title.localized(languageManager.selectedLanguage))
                .frame(maxWidth: .infinity)
                .background(viewModel.balanceAxisNuberCount == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}

extension SettingScreen {
    func balanceWeightSagmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.balanceWeightToggleChanged(to: tag)
            viewModel.saveBalanceWeghtSetting(tag)
        }) {
            Text(title.localized(languageManager.selectedLanguage))
                .frame(maxWidth: .infinity)
                .background(viewModel.balanceWeight == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}



