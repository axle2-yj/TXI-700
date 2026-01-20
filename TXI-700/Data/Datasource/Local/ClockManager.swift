//
//  ClockManager.swift
//  TXI-700
//
//  Created by 서용준 on 11/28/25.
//

import Combine
import Foundation


class ClockManager: ObservableObject {
    @Published var currentTime: String = ""
    @Published var currentDataTime : String = ""
    private var timer: Timer?
    
    init() {
        updateTime()
        time()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }
    }
    
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        currentTime = formatter.string(from: Date())
    }
    
    private func time() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        currentDataTime = formatter.string(from: Date())
    }
    
    deinit {
        timer?.invalidate()
    }
}
