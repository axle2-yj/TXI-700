//
//  PreviewView.swift
//  TXI-700
//
//  Created by 서용준 on 1/19/26.
//

import SwiftUI
import UIKit

struct PreviewBasicView: View {
    @State var loadAxleItem: LoadAxleInfo
    @ObservedObject var dataViewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @EnvironmentObject var lang: LanguageManager

    // MARK: - Computed Properties (❗️로직 전부 여기)

    private var timestampText: String {
        loadAxleItem.timestamp
            .map { printViewModel.frmatter.string(from: $0) }
            ?? "N/A"
    }

    private var dateText: String {
        loadAxleItem.timestamp
            .map { printViewModel.dateFormatter.string(from: $0) }
            ?? "N/A"
    }

    private var timeText: String {
        loadAxleItem.timestamp
            .map { printViewModel.timeFormatter.string(from: $0) }
            ?? "N/A"
    }

    private var productTitle: String {
        dataViewModel.productTitle
            .map { lang.localized($0) }
            ?? lang.localized("Item")
    }

    private var clientTitle: String {
        dataViewModel.clientTitle
            .map { lang.localized($0) }
            ?? lang.localized("Client")
    }

    private var inspectorName: String {
        (printViewModel.inspectorNameText?.isEmpty == false)
            ? "\(printViewModel.inspectorNameText!)       "
            : "------------"
    }

    // MARK: - Axle Data

    private var loadAxles: [Int] {
        guard
            let data = loadAxleItem.loadAxleData,
            let result = try? JSONDecoder().decode([Int].self, from: data)
        else { return [] }
        return result
    }

    private var axleRows: [AxleRow] {
        let totalSum = loadAxles.reduce(0, +)
        let rowCount = (loadAxles.count + 1) / 2

        return (0..<rowCount).map { rowIndex in
            let firstIndex = rowIndex * 2
            let secondIndex = firstIndex + 1

            let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
            let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0

            return AxleRow(
                index: rowIndex + 1,
                firstValue: firstValue,
                secondValue: secondValue,
                total: firstValue + secondValue,
                firstPercent: totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0,
                secondPercent: totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
            )
        }
    }

    private var summary: AxleSummary {
        let half = loadAxles.count / 2

        let first = loadAxles.prefix(half).reduce(0, +)
        let second = loadAxles.dropFirst(half).reduce(0, +)
        let left = loadAxles.enumerated().filter { $0.offset % 2 == 0 }.map(\.element).reduce(0, +)
        let right = loadAxles.enumerated().filter { $0.offset % 2 == 1 }.map(\.element).reduce(0, +)

        return AxleSummary(
            first: first,
            second: second,
            net: first - second,
            total: loadAxles.reduce(0, +),
            over: second - first,
            left: left,
            right: right
        )
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            if printViewModel.isOn(0) { Text(String(localized: "Line")) }
            if printViewModel.isOn(1) { Text(printViewModel.printHeadLineText ?? "Print Head Line") }
            if printViewModel.isOn(2) { Text(String(localized: "Line")) }

            if printViewModel.isOn(3) { Text(timestampText) }
            if printViewModel.isOn(4) { PrintPreviewLine(title: lang.localized("DATE"), value: dateText) }
            if printViewModel.isOn(5) { PrintPreviewLine(title: lang.localized("TIME"), value: timeText) }

            if printViewModel.isOn(6) { PrintPreviewLine(title: productTitle, value: loadAxleItem.product ?? "N/A") }
            if printViewModel.isOn(7) { PrintPreviewLine(title: clientTitle, value: loadAxleItem.client ?? "N/A") }
            if printViewModel.isOn(8) { PrintPreviewLine(title: lang.localized("S/N"), value: loadAxleItem.serialNumber ?? "N/A") }
            if printViewModel.isOn(9) { PrintPreviewLine(title: lang.localized("Vehicle"), value: loadAxleItem.vehicle ?? "N/A") }
            if printViewModel.isOn(10) { Text(String(localized: "Line")) }

            // MARK: Axle Rows
            ForEach(axleRows) { row in
                if printViewModel.isOn(11) {
                    PrintPreviewThreeLine(
                        title: "\(row.index)\(lang.localized("Axle"))",
                        value1: "\(row.firstValue)kg",
                        value2: "\(row.secondValue)kg"
                    )
                    Text("\(row.total)kg")
                        .frame(width: 270, alignment: .trailing)
                }

                if printViewModel.isOn(12) {
                    PrintPreviewLine(
                        title: "\(lang.localized("Weight"))\(row.index * 2 - 1)",
                        value: "\(row.firstValue)kg (\(row.firstPercent.formatted(.number.precision(.fractionLength(1))))%)"
                    )
                    PrintPreviewLine(
                        title: "\(lang.localized("Weight"))\(row.index * 2)",
                        value: "\(row.secondValue)kg (\(row.secondPercent.formatted(.number.precision(.fractionLength(1))))%)"
                    )
                }
            }

            if printViewModel.isOn(13) {
                PrintPreviewLine(title: lang.localized("1stWeight"), value: "\(summary.first)kg")
                PrintPreviewLine(title: lang.localized("2stWeight"), value: "\(summary.second)kg")
                PrintPreviewLine(title: lang.localized("NetWeight"), value: "\(summary.net)kg")
            }

            Text(String(localized: "Line"))
            PrintPreviewLine(title: lang.localized("Total"), value: "\(summary.total)kg")

            if printViewModel.isOn(14) {
                PrintPreviewLine(title: lang.localized("OverWeight"), value: "\(summary.over)kg")
            }
            if printViewModel.isOn(15) {
                PrintPreviewLine(title: lang.localized("leftWeight"), value: "\(summary.left)kg")
            }
            if printViewModel.isOn(16) {
                PrintPreviewLine(title: lang.localized("rightWeight"), value: "\(summary.right)kg")
            }

            if printViewModel.isOn(17) { Text(String(localized: "Line")) }

            if printViewModel.isOn(18) {
                HStack() { Text(lang.localized("Inspector"))
                        .frame(width: 90, alignment: .leading)
                    Text(":") .frame(width: 10, alignment: .center)
                }
                Text(inspectorName).frame(width: 260, alignment: .trailing)
            }

            if printViewModel.isOn(19) {
                HStack() {
                    Text(lang.localized("Driver"))
                        .frame(width: 90, alignment: .leading)
                    Text(":") .frame(width: 10, alignment: .center) }
                Text("------------").frame(width: 260, alignment: .trailing)
            }
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

struct PreviewTwoStepView: View {
    @State var loadAxleItem: LoadAxleInfo
    @ObservedObject var dataViewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @EnvironmentObject var lang: LanguageManager

    // MARK: - Computed Properties (❗️로직 전부 여기)

    private var timestampText: String {
        loadAxleItem.timestamp
            .map { printViewModel.frmatter.string(from: $0) }
            ?? "N/A"
    }

    private var dateText: String {
        loadAxleItem.timestamp
            .map { printViewModel.dateFormatter.string(from: $0) }
            ?? "N/A"
    }

    private var timeText: String {
        loadAxleItem.timestamp
            .map { printViewModel.timeFormatter.string(from: $0) }
            ?? "N/A"
    }

    private var productTitle: String {
        dataViewModel.productTitle
            .map { lang.localized($0) }
            ?? lang.localized("Item")
    }

    private var clientTitle: String {
        dataViewModel.clientTitle
            .map { lang.localized($0) }
            ?? lang.localized("Client")
    }

    private var inspectorName: String {
        (printViewModel.inspectorNameText?.isEmpty == false)
            ? "\(printViewModel.inspectorNameText!)       "
            : "------------"
    }

    // MARK: - Axle Data

    private var loadAxles: [Int] {
        guard
            let data = loadAxleItem.loadAxleData,
            let result = try? JSONDecoder().decode([Int].self, from: data)
        else { return [] }
        return result
    }

    private var axleRows: [AxleRow] {
        let totalSum = loadAxles.reduce(0, +)
        let rowCount = (loadAxles.count + 1) / 2

        return (0..<rowCount).map { rowIndex in
            let firstIndex = rowIndex * 2
            let secondIndex = firstIndex + 1

            let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
            let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0

            return AxleRow(
                index: rowIndex + 1,
                firstValue: firstValue,
                secondValue: secondValue,
                total: firstValue + secondValue,
                firstPercent: totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0,
                secondPercent: totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
            )
        }
    }

    private var summary: AxleSummary {
        let half = loadAxles.count / 2

        let first = loadAxles.prefix(half).reduce(0, +)
        let second = loadAxles.dropFirst(half).reduce(0, +)
        let left = loadAxles.enumerated().filter { $0.offset % 2 == 0 }.map(\.element).reduce(0, +)
        let right = loadAxles.enumerated().filter { $0.offset % 2 == 1 }.map(\.element).reduce(0, +)

        return AxleSummary(
            first: first,
            second: second,
            net: first - second,
            total: loadAxles.reduce(0, +),
            over: second - first,
            left: left,
            right: right
        )
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            if printViewModel.isOn(0) { Text(String(localized: "Line")) }
            if printViewModel.isOn(1) { Text(printViewModel.printHeadLineText ?? "Print Head Line") }
            if printViewModel.isOn(2) { Text(String(localized: "Line")) }

            if printViewModel.isOn(3) { Text(timestampText) }
            if printViewModel.isOn(4) { PrintPreviewLine(title: lang.localized("DATE"), value: dateText) }
            if printViewModel.isOn(5) { PrintPreviewLine(title: lang.localized("TIME"), value: timeText) }

            if printViewModel.isOn(6) { PrintPreviewLine(title: productTitle, value: loadAxleItem.product ?? "N/A") }
            if printViewModel.isOn(7) { PrintPreviewLine(title: clientTitle, value: loadAxleItem.client ?? "N/A") }
            if printViewModel.isOn(8) { PrintPreviewLine(title: lang.localized("S/N"), value: loadAxleItem.serialNumber ?? "N/A") }
            if printViewModel.isOn(9) { PrintPreviewLine(title: lang.localized("Vehicle"), value: loadAxleItem.vehicle ?? "N/A") }
            if printViewModel.isOn(10) { Text(String(localized: "Line")) }

            // MARK: Axle Rows
            
            
            PrintTwoStepPreviewLine(title: lang.localized("1stWeight"), value: "\(summary.first)kg")
            PrintTwoStepPreviewLine(title: lang.localized("2stWeight"), value: "\(summary.second)kg")
            PrintTwoStepPreviewLine(title: lang.localized("NetWeight"), value: "\(summary.net)kg")
            

            Text(String(localized: "Line"))
            PrintPreviewLine(title: lang.localized("Total"), value: "\(summary.total)kg")

            if printViewModel.isOn(14) {
                PrintPreviewLine(title: lang.localized("OverWeight"), value: "\(summary.over)kg")
            }
            if printViewModel.isOn(15) {
                PrintPreviewLine(title: lang.localized("leftWeight"), value: "\(summary.left)kg")
            }
            if printViewModel.isOn(16) {
                PrintPreviewLine(title: lang.localized("rightWeight"), value: "\(summary.right)kg")
            }

            if printViewModel.isOn(17) { Text(String(localized: "Line")) }

            if printViewModel.isOn(18) {
                HStack() { Text(lang.localized("Inspector"))
                        .frame(width: 90, alignment: .leading)
                    Text(":") .frame(width: 10, alignment: .center)
                }
                Text(inspectorName).frame(width: 260, alignment: .trailing)
            }

            if printViewModel.isOn(19) {
                HStack() {
                    Text(lang.localized("Driver"))
                        .frame(width: 90, alignment: .leading)
                    Text(":") .frame(width: 10, alignment: .center) }
                Text("------------").frame(width: 260, alignment: .trailing)
            }
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

struct PreviewBalacneView: View {
    @State var loadAxleItem: LoadAxleInfo
    @ObservedObject var dataViewModel: DataViewModel
    @ObservedObject var printViewModel: PrintFormSettingViewModel
    @EnvironmentObject var lang: LanguageManager

    // MARK: - Computed Properties (❗️로직 전부 여기)

    private var timestampText: String {
        loadAxleItem.timestamp
            .map { printViewModel.frmatter.string(from: $0) }
            ?? "N/A"
    }

    private var dateText: String {
        loadAxleItem.timestamp
            .map { printViewModel.dateFormatter.string(from: $0) }
            ?? "N/A"
    }
 
    private var timeText: String {
        loadAxleItem.timestamp
            .map { printViewModel.timeFormatter.string(from: $0) }
            ?? "N/A"
    }

    private var productTitle: String {
        dataViewModel.productTitle
            .map { lang.localized($0) }
            ?? lang.localized("Item")
    }

    private var clientTitle: String {
        dataViewModel.clientTitle
            .map { lang.localized($0) }
            ?? lang.localized("Client")
    }

    private var inspectorName: String {
        (printViewModel.inspectorNameText?.isEmpty == false)
            ? "\(printViewModel.inspectorNameText!)       "
            : "------------"
    }

    // MARK: - Axle Data

    private var loadAxles: [Int] {
        guard
            let data = loadAxleItem.loadAxleData,
            let result = try? JSONDecoder().decode([Int].self, from: data)
        else { return [] }
        return result
    }

    private var axleRows: [AxleBalanceRow] {
        let rowCount = (loadAxles.count + 1) / 2

        return (0..<rowCount).map { _ in

            let left1  = loadAxles[safe: 0] ?? 0
            let right1 = loadAxles[safe: 1] ?? 0
            let left2  = loadAxles[safe: 2] ?? 0
            let right2 = loadAxles[safe: 3] ?? 0
            let left3  = loadAxles[safe: 4] ?? 0
            let right3 = loadAxles[safe: 5] ?? 0
            let left4  = loadAxles[safe: 6] ?? 0
            let right4 = loadAxles[safe: 7] ?? 0
            
            let axle3 = (left3 != 0 || right3 != 0) ? left3 + right3 : 0
            let axle4 = (left4 != 0 || right4 != 0) ? left4 + right4 : 0
            let lefts  = [left1, left2, left3, left4]
            let rights = [right1, right2, right3, right4]
            let lfRr = zip(lefts, rights.dropFirst()).reduce(0) { $0 + $1.0 + $1.1 }
            let rfLr = zip(rights, lefts.dropFirst()).reduce(0) { $0 + $1.0 + $1.1 }
            
            let result = printViewModel.calculateCrossBalance(
                lefts: lefts,
                rights: rights
            )
            
            let front = left1 + right1
            let rear = left2 + right2 + axle3 + axle4
            let ltSum = lefts.reduce(0, +)
            let rtSum = rights.reduce(0, +)
            let total = front + rear
            
            let leftRatio: Double = Double(ltSum) / Double(total) * 100
            let rightRatio: Double = Double(rtSum) / Double(total) * 100
            let frontRatio: Double = Double(front) / Double(total) * 100
            let rearRatio: Double = Double(rear) / Double(total) * 100
            let lfRrRatio: Double = Double(result.lfRr) / Double(total) * 100
            let rfLrRatio: Double = Double(result.rfLr) / Double(total) * 100
            let left1Ratio: Double = Double(left1) / Double(total) * 100
            let right1Ratio: Double = Double(right1) / Double(total) * 100
            let left2Ratio: Double = Double(left2) / Double(total) * 100
            let right2Ratio: Double = Double(right2) / Double(total) * 100
            let left3Ratio: Double = Double(left3) / Double(total) * 100
            let right3Ratio: Double = Double(right3) / Double(total) * 100
            let left4Ratio: Double = Double(left4) / Double(total) * 100
            let right4Ratio: Double = Double(right4) / Double(total) * 100
            
            return AxleBalanceRow(
                left1Value: left1,
                right1Value: right1,
                left2Value: left2,
                right2Value: right2,
                left3Value: left3,
                right3Value: right3,
                left4Value: left4,
                right4Value: right4,
                left1Percent: left1Ratio,
                right1Percent: right1Ratio,
                left2Percent: left2Ratio,
                right2Percent: right2Ratio,
                left3Percent: left3Ratio,
                right3Percent: right3Ratio,
                left4Percent: left4Ratio,
                right4Percent: right4Ratio,
                leftPercent: leftRatio,
                rightPercent: rightRatio,
                frontPercent: frontRatio,
                rearPercent: rearRatio,
                lfRrRatio: lfRrRatio,
                rfLrRatio: rfLrRatio,
                front: front,
                rear: rear,
                ltSum: ltSum,
                rtSum: rtSum,
                lfRr: lfRr,
                rfLr: rfLr,
                total: total)
        }
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(String(localized: "Line"))
            Text(printViewModel.printHeadLineText ?? "Print Head Line")
            Text(String(localized: "Line"))
            
            if printViewModel.isOn(3) { Text(timestampText) }
            if printViewModel.isOn(4) { PrintPreviewLine(title: lang.localized("DATE"), value: dateText) }
            if printViewModel.isOn(5) { PrintPreviewLine(title: lang.localized("TIME"), value: timeText) }
            
            //            PrintPreviewLine(title: productTitle, value: loadAxleItem.product ?? "N/A")
            //            PrintPreviewLine(title: clientTitle, value: loadAxleItem.client ?? "N/A")
            PrintPreviewLine(title: lang.localized("S/N"), value: loadAxleItem.serialNumber ?? "N/A")
            PrintPreviewLine(title: lang.localized("Vehicle"), value: loadAxleItem.vehicle ?? "N/A")
            Text(String(localized: "Line"))
            
            // MARK: Axle Rows
            let axle = axleRows.first
            
            if axle?.left4Value != 0 && axle?.right4Value != 0 {
                PrintBalanceLine(title: "L1",value1: "\(axle?.left1Value ?? 0)kg", value2: " (\((axle?.left1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R2",value1: "\(axle?.right1Value ?? 0)kg", value2: " (\((axle?.right1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "L2",value1: "\(axle?.left2Value ?? 0)kg", value2: " (\((axle?.left2Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R2",value1: "\(axle?.right2Value ?? 0)kg", value2: " (\((axle?.right2Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "L3",value1: "\(axle?.left3Value ?? 0)kg", value2: " (\((axle?.left3Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R3",value1: "\(axle?.right3Value ?? 0)kg", value2: " (\((axle?.right3Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "L4",value1: "\(axle?.left4Value ?? 0)kg", value2: " (\((axle?.left4Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R4",value1: "\(axle?.right4Value ?? 0)kg", value2: " (\((axle?.right4Percent ?? 0.0).fixed())%)")
            } else if axle?.left3Value != 0 && axle?.right3Value != 0 {
                PrintBalanceLine(title: "L1",value1: "\(axle?.left1Value ?? 0)kg", value2: " (\((axle?.left1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R2",value1: "\(axle?.right1Value ?? 0)kg", value2: " (\((axle?.right1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "L2",value1: "\(axle?.left2Value ?? 0)kg", value2: " (\((axle?.left2Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R2",value1: "\(axle?.right2Value ?? 0)kg", value2: " (\((axle?.right2Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "L3",value1: "\(axle?.left3Value ?? 0)kg", value2: " (\((axle?.left3Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "R3",value1: "\(axle?.right3Value ?? 0)kg", value2: " (\((axle?.right3Percent ?? 0.0).fixed())%)")
            } else {
                PrintBalanceLine(title: "LF",value1: "\(axle?.left1Value ?? 0)kg", value2: " (\((axle?.left1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "RF",value1: "\(axle?.right1Value ?? 0)kg", value2: " (\((axle?.right1Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "LR",value1: "\(axle?.left2Value ?? 0)kg", value2: " (\((axle?.left2Percent ?? 0.0).fixed())%)")
                PrintBalanceLine(title: "RR",value1: "\(axle?.right2Value ?? 0)kg", value2: " (\((axle?.right2Percent ?? 0.0).fixed())%)")
            }
            
            PrintBalanceLine(title: lang.localized("FRONT"), value1: "\(axle?.front ?? 0)kg", value2: " (\((axle?.frontPercent ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("REAR"), value1: "\(axle?.rear ?? 0)kg", value2: " (\((axle?.rearPercent ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("LT SUM"), value1: "\(axle?.ltSum ?? 0)kg", value2: " (\((axle?.leftPercent ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("RT SUM"), value1: "\(axle?.rtSum ?? 0)kg", value2: " (\((axle?.rightPercent ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("LF/RR"), value1: "\(axle?.lfRr ?? 0)kg", value2: " (\((axle?.lfRrRatio ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("RF/LR"), value1: "\(axle?.rfLr ?? 0)kg", value2: " (\((axle?.rfLrRatio ?? 0.0).fixed())%)")
            PrintBalanceLine(title: lang.localized("TOTAL"), value1: "\(axle?.total ?? 0)kg", value2: "")
            
            Text(String(localized: "Line"))
            HStack() { Text(lang.localized("Inspector"))
                    .frame(width: 90, alignment: .leading)
                Text(":") .frame(width: 10, alignment: .center)
            }
            Text(inspectorName).frame(width: 260, alignment: .trailing)
            
            
            HStack() {
                Text(lang.localized("Driver"))
                    .frame(width: 90, alignment: .leading)
                Text(":") .frame(width: 10, alignment: .center) }
            Text("------------").frame(width: 260, alignment: .trailing)
            
        }
        .font(.system(size: 14, design: .monospaced))
    }
}
