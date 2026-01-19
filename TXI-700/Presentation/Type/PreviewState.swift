//
//  PreviewState.swift
//  TXI-700
//
//  Created by 서용준 on 1/19/26.
//

import Foundation

struct AxleRow: Identifiable {
    let id = UUID()
    let index: Int
    let firstValue: Int
    let secondValue: Int
    let total: Int
    let firstPercent: Double
    let secondPercent: Double
}

struct AxleSummary {
    let first: Int
    let second: Int
    let net: Int
    let total: Int
    let over: Int
    let left: Int
    let right: Int
}

struct AxleBalanceRow : Identifiable {
    let id = UUID()
    let left1Value: Int
    let right1Value: Int
    let left2Value: Int
    let right2Value: Int
    let left3Value: Int
    let right3Value: Int
    let left4Value: Int
    let right4Value: Int
    let left1Percent: Double
    let right1Percent: Double
    let left2Percent: Double
    let right2Percent: Double
    let left3Percent: Double
    let right3Percent: Double
    let left4Percent: Double
    let right4Percent: Double
    let leftPercent: Double
    let rightPercent: Double
    let frontPercent: Double
    let rearPercent: Double
    let lfRrRatio: Double
    let rfLrRatio: Double
    let front: Int
    let rear: Int
    let ltSum: Int
    let rtSum: Int
    let lfRr: Int
    let rfLr: Int
    let total: Int
}

struct AxleBalanceSummary {
    let first: Int
    let second: Int
    let third: Int
    let fourth: Int
    let fifth: Int
    let sixth: Int
    let seventh: Int
    let eighth: Int
    let total: Int
    let over: Int
    let left: Int
    let right: Int
}
