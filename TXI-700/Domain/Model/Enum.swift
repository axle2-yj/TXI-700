//
//  Enum.swift
//  TXI-700
//
//  Created by 서용준 on 1/13/26.
//
import Foundation

enum IndicatorState: Equatable {
    case idle
    // 버튼/동작 상태
    case enter
    case sum
    case print
    case cancel
    
    // 프린터 상태
    case printSend
    case printing
    case printSuccess
    case printError(PrintError)
    case saveSuccess
    // 설정/편집 상태
    case headlineSaved
    case headlineDeleted
}

enum PrintError: Equatable {
    case communication
    case noPaper
}
