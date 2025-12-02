//
//  DateRangeViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import Foundation
import SwiftUI
import Combine

class DatePickerViewModel: ObservableObject {
    @Published var startDate: Date
    @Published var endDate: Date
    
    // 최소/ 최대 날짜
    let minDate: Date
    let maxDate: Date
        
    init(endDate: Date = Date(), startDate: Date? = nil, minDate: Date = Date.distantPast, maxDate: Date = Date.distantFuture) {
            self.endDate = endDate
            // startDate가 nil이면 endDate 기준 30일 전으로 설정
            if let sDate = startDate {
                self.startDate = sDate
            } else {
                self.startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate) ?? endDate
            }
            self.minDate = minDate
            self.maxDate = maxDate
    }
    
    // yyyy/MM/dd 포맷 변환
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()
    
    var formattedRange: String {
        "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    // 시작일: 오늘 30일 전, 종료일: 오늘로 초기화
        func resetSerch() {
            let today = Date()
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
            self.startDate = thirtyDaysAgo
            self.endDate = today
        }
}
