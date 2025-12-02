//
//  DataDetailScreen.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//
//
import SwiftUI

struct DataDetailScreen: View {
    @State var currentIndex: Int
    @State var loadAxleItem: LoadAxleInfo
    
    @State private var checeked: Int? = 0
    @State private var showShareSheet = false
    @State private var activeAlert: ActiveAlert?

    @State private var deleteError: DataError?
    @State private var successMessage: String?
    @State private var printResponse: String = ""
    @State private var isPrinting: Bool = false
    @State private var selectPrintConditions : Int = 0
    @State private var isAlertShowing : Bool = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BluetoothManager

    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @ObservedObject var settingViewMdoel: SettingViewModel
    
    private var items: [LoadAxleInfo] {
            viewModel.filteredItems
        }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: -Top Bar
                CustomTopBar(title: viewModel.dataDatilTitle) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView {
                    // MARK: -프린트 미리보기 전체
                    printPreviewView
                        .padding(10)
                        .frame(maxWidth: 240)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // MARK: -Navigation Stepper
                NavigationStepper(
                    currentIndex: $currentIndex,
                    totalCount: items.count,
                    onIndexChanged: { index in
                        loadAxleItem = items[index]
                    }
                )
                .padding(.top, 5)
                
                // MARK: Segment 버튼
                HStack(spacing: 0) {
                    segmentButton(title: "Current", tag: 1)
                    segmentButton(title: "Today", tag: 2)
                    segmentButton(title: "All", tag: 3)
                }
                .frame(height: 36)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                // MARK: -Delete / Print / Send 버튼
                HStack {
                    DeleteButton(
                        viewModel: viewModel,
                        loadAxleItem: $loadAxleItem,
                        currentIndex: $currentIndex,
                        onRequestDelete: {
                            if !isAlertShowing {
                                isAlertShowing = true
                                activeAlert = .deleteConfirm
                            }
                        })
                    
                    if bleManager.isConnected {
                        let weightNumBool = Int(loadAxleItem.weightNum ?? "0") != 2
                        let printLinBuilder = if weightNumBool {
                            PrintLineBuilder.build(loadAxleItem: loadAxleItem, dataViewModel: viewModel, printViewModel: printViewModel)
                        } else {
                            PrintLineBuilder.buildTwoStepRead(loadAxleItem: loadAxleItem, dataViewModel: viewModel, printViewModel: printViewModel)
                        }
                        PrintButton(
                            isMain: false,
                            seletedType: $selectPrintConditions,
                            viewModel: viewModel,
                            printViewModel: printViewModel,
                            settingViewModel: settingViewMdoel,
                            printResponse: $printResponse,
                            lines: printLinBuilder,
                            onPrint: {
                                isPrinting = true
                                print(selectPrintConditions)
                            },
                            offPrint: {
                                isPrinting = false
                            }
                        )
                    }
                    
                    SendButton(
                        viewModel: viewModel,
                        onSendRequest: {
                            if !isAlertShowing {
                                isAlertShowing = true
                                activeAlert = .sendConfirm
                            }
                        }
                    )
                }
                .padding(.top, 4)
                
                Spacer()
            }
            
            // MARK: - BLE 프린트 응답 팝업
            .onReceive(bleManager.$printResponse) { newValue in
                guard !newValue.isEmpty else { return }
                if !isAlertShowing {
                    isAlertShowing = true
                    activeAlert = .printResponse(newValue)
                }
            }
            
            // MARK: - 데이터 이동 시 Axle 업데이트
            .onChange(of: currentIndex) { newIndex, _ in
                if items.indices.contains(newIndex) {
                    loadAxleItem = items[newIndex]
                }
            }
            
            // MARK: - 기본 Alert
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                    
                case .success(let msg):
                    return Alert(
                        title: Text(""),
                        message: Text(msg),
                        dismissButton: .default(Text("OK"))
                    )
                    
                case .error(let msg):
                    return Alert(
                        title: Text(""),
                        message: Text(msg),
                        dismissButton: .default(Text("OK"))
                    )
                    
                case .deleteConfirm:
                    return Alert(
                        title: Text("WantDelete"),
                        primaryButton: .destructive(Text("Delete")) {
                            
                            guard let realIndex =
                                    viewModel.loadAxleItems.firstIndex(where: {
                                        $0.id == loadAxleItem.id
                                    }) else {
                                if !isAlertShowing {
                                    isAlertShowing = true
                                    activeAlert = .error("Invalid Index")
                                }
                                return
                            }
                            
                            let result = viewModel.performDelete(
                                selectedIndex: realIndex,
                                loadAxleItem: &loadAxleItem,
                                currentIndex: &currentIndex
                            )
                            
                            switch result {
                            case .success(let msg):
                                if !isAlertShowing {
                                    isAlertShowing = true
                                    activeAlert = .success(msg)
                                }
                            case .failure(let err):
                                if !isAlertShowing {
                                    isAlertShowing = true
                                    activeAlert = .error(viewModel.deleteErrorMessage(err))
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                    
                case .printConfirm:
                    return Alert(
                        title: Text("WantPrint"),
                        primaryButton: .default(Text("Print")) {
                            print("프린트 실행")
                        },
                        secondaryButton: .cancel()
                    )
                    
                case .sendConfirm:
                    return Alert(
                        title: Text("WantSend"),
                        primaryButton: .default(Text("Send")) {
                            
                            let result: DataResult
                            
                            switch viewModel.selectedType {
                            case 1:
                                // 현재 선택된 1개만
                                guard let realIndex =
                                        viewModel.loadAxleItems.firstIndex(where: {
                                            $0.id == loadAxleItem.id
                                        }) else {
                                    if !isAlertShowing {
                                        isAlertShowing = true
                                        activeAlert = .error("Invalid Index")
                                    }
                                    return
                                }
                                
                                result = viewModel.preformSend(
                                    selectedIndex: realIndex,
                                    loadAxleItem: &loadAxleItem,
                                    currentIndex: &currentIndex
                                )
                                
                            case 2, 3:
                                result = viewModel.sendFilteredItems(type: .filtered)
                                
                            default:
                                return
                            }
                            
                            switch result {
                            case .success:
                                showShareSheet = true
                            case .failure(let err):
                                if !isAlertShowing {
                                    isAlertShowing = true
                                    activeAlert = .error(viewModel.sendErrorMessage(err))
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                case .printResponse(let msg):
                    return Alert(
                        title: Text(""),
                        message: Text(msg),
                        dismissButton: .default(Text("OK"), action: {
                            activeAlert = nil
                            isAlertShowing = false
                        })
                    )
                }
            }.onAppear{
                isAlertShowing = false
                activeAlert = nil
            }
            // MARK: 공유 Sheet
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [viewModel.csvURL ?? "no data"])
            }.navigationBarBackButtonHidden(true)
            
            if isPrinting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Printing...")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(viewModel.printingNumber) / \(viewModel.printTotal)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
    }
}


// MARK: - SEGMENT BUTTON

extension DataDetailScreen {
    func segmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.toggleChanged(to: tag)
            selectPrintConditions = tag - 1
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(viewModel.selectedType == tag ? Color.gray.opacity(0.4) : Color.clear)
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}

// MARK: - Print Preview View
extension DataDetailScreen {
    var printPreviewView: some View {
        let weightNum = Int(loadAxleItem.weightNum ?? "0")
        let lines = if weightNum != 2 {
            PrintLineBuilder.build(
            loadAxleItem: loadAxleItem,
            dataViewModel: viewModel,
            printViewModel: printViewModel
            )
        } else {
            PrintLineBuilder.buildTwoStepRead(
            loadAxleItem: loadAxleItem,
            dataViewModel: viewModel,
            printViewModel: printViewModel
            )
        }

        return VStack(alignment: .leading, spacing: 4) {
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
    }
}
