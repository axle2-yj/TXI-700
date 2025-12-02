//
//  LanguageManager.swift
//  TXI-700
//
//  Created by 서용준 on 12/4/25.
//

import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ko" {
        didSet {
            objectWillChange.send()   // 강제 리렌더링
        }
    }
    
    var locale: Locale {
        Locale(identifier: selectedLanguage)
    }
    
    func changeLanguage(to language: String) {
        selectedLanguage = language
    }
}
