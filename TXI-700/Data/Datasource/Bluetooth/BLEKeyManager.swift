//
//  BLEKeyManager.swift
//  TXI-700
//
//  Created by 서용준 on 1/9/26.
//
import Foundation
import Security

final class BLEKeyManager {
    
    static let shared = BLEKeyManager()
    private init() {}
    
    private let keychainKey = "com.txi700.device.uuid"
    
    /// UUID 없으면 생성, 있으면 그대로 사용
    func getDeviceUUID() -> String {
        if let uuid = loadUUID() {
            return uuid
        }
        
        let newUUID = UUID().uuidString
        saveUUID(newUUID)
        return newUUID
    }
    
    // MARK: - Keychain
    
    private func saveUUID(_ uuid: String) {
        let data = Data(uuid.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadUUID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let uuid = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return uuid
    }
}
