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
    @State private var showDeleteAlert = false
    @State private var showPrintAlert = false
    @State private var showShareSheet = false
    @State private var activeAlert: ActiveAlert?

    @State private var deleteError: DataError?
    @State private var successMessage: String?
    @State private var printResponse: String = ""
    @State private var showPrintPopup = false
    @State private var popupMessage = ""

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BluetoothManager

    @ObservedObject var viewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel

    var body: some View {
        VStack(spacing: 12) {

            // MARK: Top Bar
            CustomTopBar(title: viewModel.dataDatilTitle) {
                presentationMode.wrappedValue.dismiss()
            }

            // MARK: 프린트 미리보기 전체
            printPreviewView
                .padding(10)
                .frame(maxWidth: 240)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )

            // MARK: Navigation Stepper
            NavigationStepper(
                currentIndex: $currentIndex,
                totalCount: viewModel.loadAxleItems.count,
                onIndexChanged: { index in
                    loadAxleItem = viewModel.loadAxleItems[index]
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

            // MARK: Delete / Print / Send 버튼
            HStack {
                DeleteButton(
                    viewModel: viewModel,
                    loadAxleItem: $loadAxleItem,
                    currentIndex: $currentIndex,
                    onRequestDelete: {
                        activeAlert = .deleteConfirm
                    })

                PrintButton(
                    isMain: false,
                    seletedType: viewModel.selectedType ?? 2,
                    viewModel: viewModel,
                    printResponse: $printResponse,
                    lines: buildPrintLines()
                )

                SendButton(
                    viewModel: viewModel,
                    onSendRequest: {
                        activeAlert = .sendConfirm
                    }
                )
            }
            .padding(.top, 4)

            Spacer()
        }

        // MARK: BLE 프린트 응답 팝업
        .onReceive(bleManager.$printResponse) { newValue in
            guard !newValue.isEmpty else { return }
            popupMessage = newValue
            showPrintPopup = true
        }

        // MARK: 데이터 이동 시 Axle 업데이트
        .onChange(of: currentIndex) { newIndex, _ in
            if viewModel.loadAxleItems.indices.contains(newIndex) {
                loadAxleItem = viewModel.loadAxleItems[newIndex]
            }
        }

        // MARK: 기본 Alert
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
                        let result = viewModel.performDelete(
                            selectedIndex: currentIndex,
                            loadAxleItem: &loadAxleItem,
                            currentIndex: &currentIndex
                        )
                        switch result {
                        case .success(let msg): activeAlert = .success(msg)
                        case .failure(let err): activeAlert = .error(viewModel.deleteErrorMessage(err))
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
                        let result = viewModel.preformSend(
                            selectedIndex: currentIndex,
                            loadAxleItem: &loadAxleItem,
                            currentIndex: &currentIndex
                        )
                        switch result {
                        case .success(_):
                            showShareSheet = true
                        case .failure(let err):
                            activeAlert = .error(viewModel.deleteErrorMessage(err))
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }

        // MARK: 프린트 응답 팝업
        .alert(isPresented: $showPrintPopup) {
            Alert(
                title: Text(""),
                message: Text(popupMessage),
                dismissButton: .default(Text("OK"))
            )
        }

        // MARK: 공유 Sheet
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [viewModel.csvURL ?? "no data"])
        }

        .navigationBarBackButtonHidden(true)
    }
}


// MARK: - SEGMENT BUTTON

extension DataDetailScreen {
    func segmentButton(title: String, tag: Int) -> some View {
        Button(action: {
            viewModel.toggleChanged(to: tag)
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

// MARK: - print Content View

extension DataDetailScreen {
    var printContentView: some View {
        VStack(alignment: .leading, spacing: 0) {

            if printViewModel.isOn(0) { lineText("Line") }
            if printViewModel.isOn(1) { lineText(printViewModel.printHeadLineText ?? "Print Head Line") }
            if printViewModel.isOn(2) { lineText("Line") }

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
                simpleRow((viewModel.productTitle ?? "Item") + " : ",
                          loadAxleItem.product ?? "N/A")
            }

            if printViewModel.isOn(7) {
                simpleRow((viewModel.clientTitle ?? "Client") + " : ",
                          loadAxleItem.client ?? "N/A")
            }

            if printViewModel.isOn(8) { simpleRow("S/N :", loadAxleItem.serialNumber ?? "N/A") }
            if printViewModel.isOn(9) { simpleRow("Vehicle :", loadAxleItem.vehicle ?? "N/A") }
            if printViewModel.isOn(10) { lineText("Line") }

//            loadAxleDataView

            if printViewModel.isOn(15) { lineText("Line") }

            if printViewModel.isOn(16) {
                simpleRow("Inspector : ", printViewModel.inspectorNameText ?? "")
            }

            if printViewModel.isOn(17) {
                simpleRow("Driver : ", "")
            }
        }
    }
}

// MARK: - build PrintLines

extension DataDetailScreen {
    func buildPrintLines() -> [String] {
        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if printViewModel.isOn(3) {
            let t = loadAxleItem.timestamp.map { printViewModel.frmatter.string(from: $0) } ?? "N/A"
            lines.append(t)
        }

        if printViewModel.isOn(4) {
            let t = loadAxleItem.timestamp.map { printViewModel.dateFormatter.string(from: $0) } ?? "N/A"
            lines.append("DATE : \(t)")
        }

        if printViewModel.isOn(5) {
            let t = loadAxleItem.timestamp.map { printViewModel.timeFormatter.string(from: $0) } ?? "N/A"
            lines.append("TIME : \(t)")
        }

        if printViewModel.isOn(6) {
            lines.append("\(viewModel.productTitle ?? "Item") : \(loadAxleItem.product ?? "N/A")")
        }

        if printViewModel.isOn(7) {
            lines.append("\(viewModel.clientTitle ?? "Client") : \(loadAxleItem.client ?? "N/A")")
        }

        if printViewModel.isOn(8) { lines.append("S/N : \(loadAxleItem.serialNumber ?? "N/A")") }
        if printViewModel.isOn(9) { lines.append("Vehicle : \(loadAxleItem.vehicle ?? "N/A")") }
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }

        // MARK: Load Axles 출력
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
            
            let rowCount = (loadAxles.count + 1) / 2
            let totalSum = loadAxles.reduce(0, +)
            
            for rowIndex in 0..<rowCount {
                let firstIndex = rowIndex * 2
                let secondIndex = firstIndex + 1

                let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
                let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0

                if printViewModel.isOn(11) {
                    lines.append("\(rowIndex + 1)Axle : \(firstValue)kg/ \(secondValue)kg")
                    lines.append("\(firstValue + secondValue)kg")
                }

                if printViewModel.isOn(12) {
                    let firstPercent = totalSum > 0 ? (Double(firstValue) / Double(totalSum)) * 100 : 0
                    let secondPercent = totalSum > 0 ? (Double(secondValue) / Double(totalSum)) * 100 : 0
                    
                    lines.append("Weight\(rowIndex+1) : \(firstValue)kg (\(String(format: "%.1f", firstPercent))%)")
                    lines.append("Weight\(rowIndex+2) : \(secondValue)kg (\(String(format: "%.1f", secondPercent))%)")
                }
            }
        

            let first = loadAxles.indices.contains(0) && loadAxles.indices.contains(1) ? loadAxles[0] + loadAxles[1] : 0
            let second = loadAxles.indices.contains(2) && loadAxles.indices.contains(3) ? loadAxles[2] + loadAxles[3] : 0

            if printViewModel.isOn(13) {
                lines.append("1st Weight : \(first)")
                lines.append("2st Weight : \(second)")
                lines.append("Net Weight : \(first - second)")
            }

            lines.append(String(localized: "Line"))
            lines.append("Total : \(totalSum)")

            if printViewModel.isOn(14) {
                lines.append("over : \(first - second)")
            }
        }

        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector : \(printViewModel.inspectorNameText ?? "")") }
        if printViewModel.isOn(17) { lines.append("Driver : ") }

        return lines
    }
}

// MARK: - Print Preview View
extension DataDetailScreen {
    var printPreviewView: some View {
        let lines = buildPrintLines()

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
//
//// MARK: - loadAxle Data View
//extension DataDetailScreen {
//    var loadAxleDataView: some View {
//        VStack(alignment: .leading, spacing: 4) {
//
//            if let data = loadAxleItem.loadAxleData,
//               let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
//
//                let totalSum = loadAxles.reduce(0, +)
//
//                ForEach(loadAxles.indices, id: \.self) { i in
//                    let weight = loadAxles[i]
//                    let percent = totalSum > 0 ? (Double(weight) / Double(totalSum)) * 100 : 0
//
//                    HStack {
//                        Text("Axle \(i+1)")
//                        Spacer()
//                        Text("\(weight)kg")
//                        Text("(\(String(format: "%.1f", percent))%)")
//                    }
//                }
//
//                lineText("Line")
//                simpleRow("Total :", String(totalSum))
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}

