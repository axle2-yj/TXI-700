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
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @ObservedObject var settingViewMdoel: SettingViewModel
    
    private var items: [LoadAxleInfo] {
        viewModel.filteredItems
    }
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        ZStack {
            VStack {
                // MARK: -Top Bar
                CustomTopBar(title: viewModel.dataDatilTitle) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView {
                    // MARK: -프린트 미리보기 전체
                    VStack{
                        let weightNum = Int(loadAxleItem.weightNum ?? "0")
                        if weightNum == 3 {
                            PreviewBalacneView(loadAxleItem: loadAxleItem, dataViewModel: viewModel, printViewModel: printViewModel)
                        } else if weightNum == 2{
                            PreviewTwoStepView(loadAxleItem: loadAxleItem, dataViewModel: viewModel, printViewModel: printViewModel)
                        } else {
                            PreviewBasicView(loadAxleItem: loadAxleItem, dataViewModel: viewModel, printViewModel: printViewModel)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: 300)
                    .foregroundStyle(Color.black)
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
                Spacer()
                
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
                        }).disabled(viewModel.selectedType == nil)
                    
                    if !bleManager.isDisconnected {
                        let twoStepWight = Int(loadAxleItem.weightNum ?? "0") == 2
                        let balanceWight = Int(loadAxleItem.weightNum ?? "0") == 3
                        let printLinBuilder = if twoStepWight {
                            PrintLineBuilder.buildPrintTwoStepLineData(
                                loadAxleItem: loadAxleItem,
                                dataViewModel: viewModel,
                                printViewModel: printViewModel,
                                lang: languageManager)
                        } else if balanceWight{
                            PrintLineBuilder.buildPrintBalanceLinesData(
                                loadAxleItem: loadAxleItem,
                                dataViewModel: viewModel,
                                printViewModel: printViewModel,
                                lang: languageManager
                            )
                        } else {
                            PrintLineBuilder.buildPrintOneStepLineData(
                                loadAxleItem: loadAxleItem,
                                dataViewModel: viewModel,
                                printViewModel: printViewModel,
                                lang: languageManager)
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
                                print("selectPrintConditions : \(selectPrintConditions)")
                            },
                            offPrint: {
                                isPrinting = false
                            }
                        ).disabled(viewModel.selectedType == nil)
                    }
                    
                    SendButton(
                        viewModel: viewModel,
                        onSendRequest: {
                            if !isAlertShowing {
                                isAlertShowing = true
                                activeAlert = .sendConfirm
                            }
                        }
                    ).disabled(viewModel.selectedType == nil)
                }
                .frame(height: 25)
                .padding(.top, 10)
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
                        dismissButton: .default(Text("Confirmation"))
                    )
                    
                case .error(let msg):
                    return Alert(
                        title: Text(""),
                        message: Text(msg),
                        dismissButton: .default(Text("Confirmation"))
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
                            isAlertShowing = false
                        },
                        secondaryButton: .destructive(Text("Cancel")) {
                            isAlertShowing = false
                        }
                    )
                    
                case .printConfirm:
                    return Alert(
                        title: Text("WantPrint"),
                        primaryButton: .default(Text("Print")) {
                            print("프린트 실행")
                            isAlertShowing = false
                        },
                        secondaryButton: .destructive(Text("Cancel")) {
                            isAlertShowing = false
                        }
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
                                
                                //                                sendPayload()         // 단건 JSON 파일 전송 Bluetooth
                            case 2, 3:
                                result = viewModel.sendFilteredItems(type: .filtered)
                                
                                //                                multipleSendPayload(viewModel.selectedType ?? 1) // 다건 JSON 파일 전송 Bluetooth
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
                            
                            isAlertShowing = false
                        },
                        secondaryButton: .destructive(Text("Cancel")) {
                            isAlertShowing = false
                        }
                    )
                case .printResponse(let msg):
                    return Alert(
                        title: Text(""),
                        message: Text(msg),
                        dismissButton: .default(Text("Confirmation"), action: {
                            activeAlert = nil
                            isAlertShowing = false
                        })
                    )
                }
            }.onAppear{
                isAlertShowing = false
                activeAlert = nil
            }.onDisappear {
                viewModel.selectedType = nil
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
                .foregroundColor(tint)
                .cornerRadius(6)
        }
    }
}

extension DataDetailScreen {
    func sendPayload() {
        let total = viewModel.sumLoadAxleData(loadAxleItem.loadAxleData)
        
        let payload = PrintPayload(
            printHeadLine: printViewModel.printHeadLineText ?? "",
            date: ISO8601DateFormatter().string(
                from: loadAxleItem.timestamp ?? Date()
            ),
            item: loadAxleItem.product ?? "",
            client: loadAxleItem.client ?? "",
            serialNumber: loadAxleItem.serialNumber ?? "",
            vehicleNumber: loadAxleItem.vehicle ?? "",
            equipmentNumber: loadAxleItem.equipmentNumber ?? "",
            loadAxle: viewModel.decodeLoadAxleData(loadAxleItem.loadAxleData ?? Data()),
            weight: loadAxleItem.weightNum ?? "",
            total: String(total),
            inspector: printViewModel.inspectorNameText ?? ""
        )
        // 1️⃣ BLE
        bleManager.sendToJsonCommand(items: [payload])
        
        // 2️⃣ Server
        viewModel.sendToServer(payloads: [payload]) { success in
            print(success ? "서버 저장 완료" : "서버 저장 실패")
        }
    }
    
    func multipleSendPayload(_ state: Int) {
        // MARK: - JSON 형태로 전달 방식
        let selectedItems: [LoadAxleInfo] = viewModel.loadAxleItems
        let payloads = viewModel.makePrintPayloads(
            items: selectedItems,
            printViewModel: printViewModel
        )
        
        // 1️⃣ BLE
        bleManager.sendToJsonCommand(items: payloads)
        
        // 2️⃣ Server
        viewModel.sendToServer(payloads: payloads) { success in
            if state == 1 {
                print(success ? "오늘 데이터 서버 전송 완료" : "오늘 데이터 서버 전송 실패")
            } else {
                print(success ? "전체 데이터 서버 전송 완료" : "전체 데이터 서버 전송 실패")
            }
        }
    }
}
