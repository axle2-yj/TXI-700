//
//  SettingViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class SettingViewModel: ObservableObject {
    @Published var title: String = NSLocalizedString("SettingsScreenTitle", comment: "")
    @Published var language = 0
    @Published var weightingMethod = 0
    @Published var modeName = "Static"
    @Published var modeInt: Int? = 0
    @Published var imageName = "car_static"
    @Published var isModeButtonDisabled = false
    @Published var saveProduct: String? = nil
    @Published var saveClient: String? = nil
    @Published var checkedProduct: Bool = false
    @Published var checkedClient: Bool = false
    @Published var printOutputCount: Int = 0

    func reset() {
        
    }
    
    // 0 = 영어, 1 = 일어, 2 = 한국어
    func toggleChanged(to newValue: Int) {
        language = newValue
    }
    
    func weightToggleChanged(to newValue: Int) {
        weightingMethod = newValue
    }
    
    func printOutputToggleChanged(to newValue: Int) {
        printOutputCount = newValue
    }
    
    // 언어 저장
    func saveLanguage(_ language: Int) {
        StorageManager.shared.saveLanguage(language)
    }
    
    // Weight Method 저장
    func saveWeightingMethod(_ method: Int) {
        StorageManager.shared.saveWeighingMethod(method)
    }
    
    // Product명 호출
    func loadProduct() {
        saveProduct = StorageManager.shared.loadProductTitle()
    }
    
    // Client명 호출
    func loadClient() {
        saveClient = StorageManager.shared.loadClientTitle()
    }
        
    // 언어 호출
    func loadLanguage() {
        language = StorageManager.shared.loadLanguage() ?? 0
    }
    
    // Mode 저장
    func saveModeChange(_ mode: Int) {
        StorageManager.shared.saveModeChange(mode)
    }
        
    // Weighting Method 호출
    func loadWeightingMethod() {
        weightingMethod = StorageManager.shared.loadWeighingMethod() ?? 0
    }
    
    // Mode 호출
    func loadModeChange() {
        modeInt = StorageManager.shared.loadModeChange()
        let mode = self.modeInt ?? 0
        switch mode {
            case 0:
                self.modeName = "Static"
                self.imageName = "car_static"
            case 1:
                self.modeName = "Inmotion"
                self.imageName = "car_inmotion"
            case 2:
                self.modeName = "Auto Inmotion"
                self.imageName = "car_auto_inmotion"
            default:
                self.modeName = "Static"
                self.imageName = "car_static"
        }
    }
    
    // Product 저장
    func saveProductCkeck(_ isOn: Bool) {
        StorageManager.shared.saveProductCheked(isOn)
    }
    
    // Client 저장
    func saveClientCkeck(_ isOn: Bool) {
        StorageManager.shared.saveClientChecked(isOn)
    }
    
    // Product 호출
    func loadProductCkeck() {
        checkedProduct = StorageManager.shared.loadProductCheked()
    }
    
    // Client 호출
    func loadClientCkeck() {
        checkedClient = StorageManager.shared.loadClientChecked()
    }
    
    // Mode 변경시 버튼 사용 금지
    func disableButton() {
        isModeButtonDisabled = true
    }

    // Mode 변경 완료 후 버튼 사용 가능
    func enableButton() {
        isModeButtonDisabled = false
    }
    
    func savePrintOutputCountSetting(_ count: Int) {
        StorageManager.shared.savePrintOutputCount(count)
    }
    
    func loadPrintOutputCountSetting() {
        printOutputCount = StorageManager.shared.loadPrintOutputCount()
    }
}
