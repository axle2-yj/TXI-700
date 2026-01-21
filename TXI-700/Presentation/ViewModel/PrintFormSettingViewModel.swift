//
//  SettingDataPrintViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class PrintFormSettingViewModel: ObservableObject {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @Published var text: String = NSLocalizedString("SettingsDataScreenTitle", comment: "")
    @Published var printHeadLineText: String? = nil
    @Published var clientTitle: String? = nil
    @Published var productTitle: String? = nil
    @Published var toggles: [Bool] = []
    @Published var inspectorNameText: String? = nil
    @Published var overValue: Int = 100000
    @Published var allItems: [LoadAxleInfo] = []
    @Published var isDelete = false
    /// labels는 템플릿 문자열
    private let baseLabels: [String] = [
        "Bar","HeadLine","Bar",                        // 0, 1, 2
        "date_time","DATE","TIME",                     // 3, 4, 5
        "{PRODUCT}", "{CLIENT}", "S/N",                // 6, 7, 8
        "Vehicle","Bar","Step(Standard)",              // 9, 10, 11
        "each","Two-StepWeighing","OverWeight",        // 12, 13, 14
        "leftWeight","rightWeight",                    // 15, 16,
        "Bar","Inspector","Driver"                     // 17, 18, 19
    ]
    
    let frmatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    /// UI에서 실제 사용할 labels (동적으로 변환됨)
    var labels: [String] {
        baseLabels.map {
            $0.replacingOccurrences(of: "{PRODUCT}", with: productTitle ?? "Item")
                .replacingOccurrences(of: "{CLIENT}", with: clientTitle ?? "Client")
        }
    }
    
    @Published var defaultToggles: [Bool] = [
        true, true, true,
        true, false, false,
        true, true, true,
        true, true, true,
        false, false, false,
        false, false,
        true, true, false
    ]
    
    init() {
        loadProductTitle()
        loadClientTitle()
        loadPrintHeadLine()
        loadInspectorName()
        loadOverValue()
        setInitialValuesIfNeeded()
        if let saved = StorageManager.shared.loadToggles(),
           saved.count == baseLabels.count {
            toggles = saved
        } else {
            toggles = defaultToggles
        }
    }
    
    // MARK: - Toggle 저장 및 로드
    func toggleChanged(index: Int, value: Bool) {
        toggles[index] = value
        
        // --- 3, 4, 5번 연동 로직 추가 ---
        let idxDateTime = 3
        let idxDate = 4
        let idxTime = 5
        
        // --- 11, 12, 13 ---
        let idxStep = 11
        let idxEach = 12
        let idxTwoStep = 13
        
        // -------------------------------
        // 3, 4, 5 상호 배타 로직
        // -------------------------------
        switch index {
        case idxDateTime: // 3번이 바뀜
            if value == true {
                // 3이 true → 4,5는 false
                toggles[idxDate] = false
                toggles[idxTime] = false
            }
            
        case idxDate, idxTime: // 4 또는 5가 바뀜
            if value == true {
                // 4 또는 5가 true → 3은 false
                toggles[idxDateTime] = false
            }
            
        default:
            break
        }
        // -------------------------------
        // 11, 12, 13 상호 배타 + 반드시 1개 true 유지
        // -------------------------------
        if [idxStep, idxEach, idxTwoStep].contains(index) {
            if value == true {
                // 선택된 index 외의 두 개는 false
                let trio = [idxStep, idxEach, idxTwoStep]
                for i in trio where i != index {
                    toggles[i] = false
                }
            } else {
                let trio = [idxStep, idxEach, idxTwoStep]
                let trueCount = trio.filter { toggles[$0] }.count
                
                if trueCount == 0 {
                    toggles[index] = true
                }
            }
        }
        
        saveToggles()
        
        objectWillChange.send()
    }
    
    
    func saveToggles() {
        StorageManager.shared.saveToggles(toggles)
    }
    
    func loadToggles() {
        if let saved = StorageManager.shared.loadToggles(),
           saved.count == defaultToggles.count {
            toggles = saved
        } else {
            toggles = defaultToggles
            saveToggles()
        }
    }
    
    func isOn(_ index: Int) -> Bool {
        toggles.indices.contains(index) && toggles[index]
    }
    
    // MARK: - Title 저장
    func saveProductTitle(_ text: String) {
        StorageManager.shared.saveProductTitle(text)
        productTitle = text
    }
    
    func saveClientTitle(_ text: String) {
        StorageManager.shared.saveClientTitle(text)
        clientTitle = text
    }
    
    func loadProductTitle() {
        productTitle = StorageManager.shared.loadProductTitle()
    }
    
    func loadClientTitle() {
        clientTitle = StorageManager.shared.loadClientTitle()
    }
    
    func savePrintHeadLine(_ text: String) {
        print("viewmodel : \(text)")
        StorageManager.shared.savePrintHeadLine(text)
    }
    
    func loadPrintHeadLine() {
        printHeadLineText = StorageManager.shared.loadPrintHeadLine()
    }
    
    func saveInspectorName(_ text: String) {
        StorageManager.shared.saveInspecterName(text)
    }
    
    func loadInspectorName() {
        inspectorNameText = StorageManager.shared.loadInspecterName()
    }
    
    func saveOverValue(_ weight: Int) {
        StorageManager.shared.saveOverValue(weight)
    }
    
    func loadOverValue() {
        overValue = StorageManager.shared.loadOverValue()
    }
    
    func calculateCrossBalance(
        lefts: [Int],
        rights: [Int]
    ) -> (lfRr: Int, rfLr: Int) {
        
        // 0은 존재하지 않는 축으로 간주
        let validLefts  = lefts.filter { $0 > 0 }
        let validRights = rights.filter { $0 > 0 }
        
        // 최소 2축 필요
        guard validLefts.count >= 2,
              validRights.count >= 2 else {
            return (0, 0)
        }
        
        // 앞축
        let frontLeft  = validLefts.first!
        let frontRight = validRights.first!
        
        // 뒤축 (3축 이상이 없을 수도 있으므로 "마지막 유효 축")
        let rearLeft   = validLefts.last!
        let rearRight  = validRights.last!
        
        let lfRr = frontLeft + rearRight   // LF + RR
        let rfLr = frontRight + rearLeft   // RF + LR
        
        return (lfRr, rfLr)
    }
    
    private func setInitialValuesIfNeeded() {
        guard !hasLaunchedBefore else { return }
        
        // ✅ 최초 실행 시에만 초기값
        saveOverValue(overValue)
        
        // 이후 실행 방지
        hasLaunchedBefore = true
    }
}

