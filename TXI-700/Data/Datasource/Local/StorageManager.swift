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
    
    func saveProdoctTitle(_ title: String) {
        UserDefaults.standard.set(title, forKey: productTitle)
    }
    
    func loadProdoctTitle() -> String? {
        return UserDefaults.standard.string(forKey: productTitle)
    }
    
    func clearProdoctTitle() {
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

}
