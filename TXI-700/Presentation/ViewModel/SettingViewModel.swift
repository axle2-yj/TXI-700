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
    @Published var weightingMethod : Int? = 0
    @Published var modeName = "Static"
    @Published var modeInt: Int? = 0
   
    
    func reset() {
        
    }
    
    func saveWeightingMethod(_ method: Int) {
        StorageManager.shared.saveWeighingMethod(method)
    }
    
    func loadWeightingMethod() {
        weightingMethod = StorageManager.shared.loadWeighingMethod()
        switch weightingMethod ?? 0 {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                break
            default:
                break
        }
    }
    
    func saveModeChange(_ mode: Int) {
        StorageManager.shared.saveModeChange(mode)
    }
    
    func loadModeChange() {
        modeInt = StorageManager.shared.loadModeChange()
        let mode = self.modeInt ?? 0
        switch mode {
            case 0:
                self.modeName = "Static"
            case 1:
                self.modeName = "Inmotion"
            case 2:
                self.modeName = "Auto Inmotion"
            default:
                self.modeName = "Static"
        }
    }
    
    
}
