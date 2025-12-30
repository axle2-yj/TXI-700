//
//  handleAuthChallenge.swift
//  TXI-700
//
//  Created by 서용준 on 1/9/26.
//

import Foundation
import CryptoKit
import CoreBluetooth

// MARK: - Auth
extension BluetoothManager {
    
    // MARK: - 인증 요청 (Connect 직후 호출)
    func sendAuthRequest() {
        guard let peripheral = connectedPeripheral,
              let authChar = authResponseChar else { return }
        
        let uuid = BLEKeyManager.shared.getDeviceUUID()
        let data = Data([UInt8(uuid.count)]) + Data(uuid.utf8)
        
        peripheral.writeValue(data, for: authChar, type: .withResponse)
    }
    
    // MARK: - 인증 성공 (하드웨어 무응답 or OK 수신)
    func handleAuthSuccess() {
        DispatchQueue.main.async {
            self.isAuthenticated = true
            print("✅ BLE 인증 성공")
            
            // 🔽 기존 초기 명령 유지
            self.sendInitialModeCallCommand()
            self.sendInitialSNCallCommand()
            self.sendEquipmentNumberCall()
        }
    }
    
    // MARK: - 인증 실패 (다른 기기 접근)
    func handleAuthFailure() {
        isAuthenticated = false
        showAuthAlert = true
    }
    
    // MARK: - Payload 생성
    private func buildAuthPayload(deviceUUID: String,
                                  authCode: String) -> Data {
        
        /*
         Payload Format (예시)
         [UUID Length][UUID UTF8][CODE UTF8]
         
         UUID Length: 1 byte
         UUID: variable
         CODE: 6 bytes
         */
        
        var data = Data()
        
        let uuidData = Data(deviceUUID.utf8)
        let codeData = Data(authCode.utf8)
        
        data.append(UInt8(uuidData.count))
        data.append(uuidData)
        data.append(codeData)
        
        return data
    }
    
    func startAuthTimeout() {
        authTimeoutWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if !self.isAuthenticated {
                self.handleAuthSuccess()
            }
        }
        
        authTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}
