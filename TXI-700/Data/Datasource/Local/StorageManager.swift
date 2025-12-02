//
//  StorageManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/26/25.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    private init() {}

    private let macKey = "saved_mac_address"
    private let productTitle = "ITEM <<"
    private let clientTitel = "CLIENT <<"
    private let autoScen = "auto_scan"
    private let weighingMethod = "Onetime"
    private let modeChange = "modeChange"
    private let languageKey = "language"
    private let printToggles =  "printToggles"
    private let printHeadLine = "printHeadLine"
    private let inspector = "inspector"
    private let productChecked = "productChecked"
    private let clientChecked = "clientChecked"
    private let serialNumber = "serialNumber"
    private let printOutputCount = "printOutputCount"
    
    // MAC 저장
    func saveMacAddress(_ mac: String) {
        UserDefaults.standard.set(mac, forKey: macKey)
    }

    // MAC 읽기
    func loadMacAddress() -> String? {
        return UserDefaults.standard.string(forKey: macKey)
    } 

    // MAC 삭제
    func clearMacAddress() {
        UserDefaults.standard.removeObject(forKey: macKey)
    }
    
    func saveProductTitle(_ title: String) {
        UserDefaults.standard.set(title, forKey: productTitle)
    }
    
    func loadProductTitle() -> String? {
        return UserDefaults.standard.string(forKey: productTitle)
    }
    
    func clearProductTitle() {
        UserDefaults.standard.removeObject(forKey: productTitle)
    }
    
    func saveClientTitle(_ title: String) {
        UserDefaults.standard.set(title, forKey: clientTitel)
    }
    
    func loadClientTitle() -> String? {
        return UserDefaults.standard.string(forKey: clientTitel)
    }
    
    func clearClientTitle() {
        UserDefaults.standard.removeObject(forKey: clientTitel)
    }
    
    func saveAutoScan(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: autoScen)
    }
    
    func loadAutoScan() -> Bool {
        return UserDefaults.standard.bool(forKey: autoScen)
    }
    
    func saveWeighingMethod(_ method: Int) {
        UserDefaults.standard.set(method, forKey: weighingMethod)
    }
    
    func loadWeighingMethod() -> Int? {
        return UserDefaults.standard.integer(forKey: weighingMethod)
    }
    
    func clearWeighingMethod() {
        UserDefaults.standard.removeObject(forKey: weighingMethod)
    }
    
    func saveModeChange(_ mode: Int) {
        UserDefaults.standard.set(mode, forKey: modeChange)
    }
      
    func loadModeChange() -> Int? {
        return UserDefaults.standard.integer(forKey: modeChange)
    }
    
    func saveLanguage(_ language: Int) {
        UserDefaults.standard.set(language, forKey: languageKey)
    }
    
    func loadLanguage() -> Int? {
        return UserDefaults.standard.integer(forKey: languageKey)
    }
    
    func saveToggles(_ values: [Bool]) {
        UserDefaults.standard.set(values, forKey: printToggles)
    }
    
    func loadToggles() -> [Bool]? {
        return UserDefaults.standard.array(forKey: printToggles) as? [Bool]
    }
    
    func savePrintHeadLine(_ value: String) {
        UserDefaults.standard.set(value, forKey: printHeadLine)
    }
    
    func loadPrintHeadLine() -> String? {
        return UserDefaults.standard.string(forKey: printHeadLine)
    }
    
    func saveInspecterName(_ name: String) {
        UserDefaults.standard.set(name, forKey: inspector)
    }
    
    func loadInspecterName() -> String? {
        return UserDefaults.standard.string(forKey: inspector)
    }
    
    func saveProductCheked(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: productChecked)
    }
    
    func loadProductCheked() -> Bool {
        return UserDefaults.standard.bool(forKey: productChecked)
    }
    
    func saveClientChecked(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: clientChecked)
    }
    
    func loadClientChecked() -> Bool {
        return UserDefaults.standard.bool(forKey: clientChecked)
    }
    
    func saveSerialNumber(_ sn: Int){
        UserDefaults.standard.set(sn, forKey: serialNumber)
    }
    
    func loadSerialNumber() -> Int {
        return UserDefaults.standard.integer(forKey: serialNumber)
    }
    
    func savePrintOutputCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: printOutputCount)
    }
    
    func loadPrintOutputCount() -> Int {
        return UserDefaults.standard.integer(forKey: printOutputCount)
    }
}
