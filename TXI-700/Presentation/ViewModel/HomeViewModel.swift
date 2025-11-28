//
//  HomeViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var text: String = NSLocalizedString("HomeScreenTitle", comment: "")
    
    @Published var savedMac: String? = nil

        func saveDeviceMac(_ mac: String) {
            StorageManager.shared.saveMacAddress(mac)
            // 저장 후 바로 로컬 변수에 반영
            savedMac = mac
        }

        func loadDeviceMac() {
            savedMac = StorageManager.shared.loadMacAddress()
        }

        func clearMac() {
            StorageManager.shared.clearMacAddress()
            savedMac = nil
        }
}
