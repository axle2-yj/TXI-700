//
//  BLEResponse.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

enum BLEResponse {
    case enterOrCancel
    case sumOrPrint
    case headlineDeleted
    case headlineSaved
    case battery(level: Int)
    case weight(axle: Int, value: Int)
    case sirealNumberChecke(Int)
    case serialNumber(Int)
    case unknown([UInt8])
    case staticMode
    case inmotionMode
    case autoInmotionMode
    case printSend
    case printErrorCommunication
    case printing
    case printErrorPaper
    case printSuccess
    case itemCall([UInt8])
    case clientCall([UInt8])
    case vehicle([UInt8])
    case equipment([UInt8])
    case language([UInt8])
    case rf([UInt8])
    case dataCall([UInt8])
    case settingCall([UInt8])
}
