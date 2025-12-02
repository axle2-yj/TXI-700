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

    @ObservedObject var viewModel: SettingViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        VStack(spacing : 0) {
            CustomTopBar(title: viewModel.title, onBack: {
                presentationMode.wrappedValue.dismiss()
            })
            VStack {
                HStack {
                    VStack {
                        Text("Lenguge")
                        HStack {
                            Button("English") {
                                viewModel.saveWeightingMethod(0)
                                languageManager.changeLanguage(to: "en")
                            }
                            Spacer()
                            Button("Japanese") {
                                viewModel.saveWeightingMethod(1)
                                languageManager.changeLanguage(to: "ja")
                            }
                            Spacer()
                            Button("Korean") {
                                viewModel.saveWeightingMethod(2)
                                languageManager.changeLanguage(to: "ko")
                            }
                        }
                        
                    }.padding()
                }.frame(maxWidth: .infinity)
                    .padding()
                
                HStack {
                    VStack {
                        Text("Mode Change")
                        Button(String(viewModel.modeName)) {
                            switch viewModel.modeInt {
                            case 0:
                                viewModel.saveModeChange(1)
                            case 1:
                                viewModel.saveModeChange(2)
                            case 2:
                                viewModel.saveModeChange(0)
                            default :
                                break
                            }
                            viewModel.loadModeChange()
                        }.padding()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .foregroundColor(.black)
                    }.frame(maxWidth: .infinity)
                        .padding()
                    VStack {
                        Text("Print Form")
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
                
                HStack {
                    Text("PrintHeadline")
                    TextField("PrintHeadLineText", text: Binding(
                            get: {printViewModel.printHeadLineText ?? "Print HeadLine Text"},
                            set: {printViewModel.printHeadLineText = $0}
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    Button(action: {
                        printViewModel.savePrintHeadLine(printViewModel.printHeadLineText ?? "")
                    }) {
                        Image(systemName: "return")
                            .font(.title2)
                            .padding(8)
                    }
                }
                
                Spacer()
            }.navigationBarBackButtonHidden(true).padding()
        }.onAppear {
            viewModel.loadModeChange()
            printViewModel.loadPrintHeadLine()
        }
    }
    
}
