//
//  PrintForm.swift
//  TXI-700
//
//  Created by 서용준 on 12/16/25.
//

import SwiftUI
import Foundation

struct PrintLineBuilder {

    static func build(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {

        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if printViewModel.isOn(3) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.frmatter.string(from: $0)
            } ?? "N/A"
            lines.append(t)
        }

        if printViewModel.isOn(4) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.dateFormatter.string(from: $0)
            } ?? "N/A"
            lines.append("DATE : \(t)")
        }

        if printViewModel.isOn(5) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.timeFormatter.string(from: $0)
            } ?? "N/A"
            lines.append("TIME : \(t)")
        }

        if printViewModel.isOn(6) {
            lines.append("\(dataViewModel.productTitle ?? "Item") : \(loadAxleItem.product ?? "N/A")")
        }

        if printViewModel.isOn(7) {
            lines.append("\(dataViewModel.clientTitle ?? "Client") : \(loadAxleItem.client ?? "N/A")")
        }

        if printViewModel.isOn(8) { lines.append("S/N : \(loadAxleItem.serialNumber ?? "N/A")") }
        if printViewModel.isOn(9) { lines.append("Vehicle : \(loadAxleItem.vehicle ?? "N/A")") }
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }

        // MARK: Load Axles
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
            let rowCount = (loadAxles.count + 1) / 2
            let totalSum = loadAxles.reduce(0, +)

            for rowIndex in 0..<rowCount {
                let firstIndex = rowIndex * 2
                let secondIndex = firstIndex + 1

                let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
                let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0

                if printViewModel.isOn(11) {
                    lines.append("\(rowIndex + 1)Axle : \(firstValue)kg/ \(secondValue)kg")
                    lines.append("                      \(firstValue + secondValue)kg")
                }

                if printViewModel.isOn(12) {
                    let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                    let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
                    let firstWeightIndex = firstIndex + 1
                    let secondWeightIndex = secondIndex + 1
                    
                    lines.append(
                        "Weight\(firstWeightIndex) : \(firstValue)kg (\(String(format: "%.1f", firstPercent))%)"
                    )
                    lines.append(
                        "Weight\(secondWeightIndex) : \(secondValue)kg (\(String(format: "%.1f", secondPercent))%)"
                    )
                }
            }

            let count = loadAxles.count
            let half = count / 2

            let first = loadAxles.prefix(half).reduce(0, +)
            let second = loadAxles.dropFirst(half).reduce(0, +)

            if printViewModel.isOn(13) {
                lines.append("1st Weight : \(first)kg")
                lines.append("2st Weight : \(second)kg")
                lines.append("Net Weight : \(first - second)kg")
            }

            lines.append(String(localized: "Line"))
            lines.append("Total : \(totalSum)kg")

            if printViewModel.isOn(14) {
                lines.append("over : \(first - second)kg")
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
            ? printViewModel.inspectorNameText ?? ""
            : "____________"
        
        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(17) { lines.append("Driver :           ____________") }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")

        return lines
    }
    
    static func buildSecond(
        loadAxleItem: [LoadAxleStatus],
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        timeStamp: Date,
        item: String,
        client : String,
        vehicle : String,
        serialNumber: String,
        selectedType: Int
    )
    -> [String] {

        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if printViewModel.isOn(3) {
            let t = printViewModel.frmatter.string(from: timeStamp)
            lines.append(t)
        }

        if printViewModel.isOn(4) {
            let t = printViewModel.dateFormatter.string(from: timeStamp)
            lines.append("DATE : \(t)")
        }

        if printViewModel.isOn(5) {
            let t =  printViewModel.timeFormatter.string(from: timeStamp)
            lines.append("TIME : \(t)")
        }

        let itemCheck = if dataViewModel.productTitle == item { "N/A" } else { item }
        let clientCheck = if dataViewModel.clientTitle == client { "N/A" } else { client }
        let vehicleCheck = if vehicle.isEmpty { "N/A" } else { vehicle }
        
        if printViewModel.isOn(6) {
            lines.append("\(dataViewModel.productTitle ?? "Item") : \(itemCheck)")
        }

        if printViewModel.isOn(7) {
            lines.append("\(dataViewModel.clientTitle ?? "Client") : \(clientCheck)")
        }
        
        if printViewModel.isOn(8) { lines.append("S/N : \(serialNumber)") }
        if printViewModel.isOn(9) { lines.append("Vehicle : \(vehicleCheck)") }
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }

    // MARK: Load Axles
        if !loadAxleItem.isEmpty{
            for axleStatus in loadAxleItem {
                
                let loadAxles = axleStatus.loadAxlesData
                let totalSum = axleStatus.total
                let rowCount = (loadAxles.count + 1) / 2
                
                for rowIndex in 0..<rowCount {
                    let firstIndex = rowIndex * 2
                    let secondIndex = firstIndex + 1
                    
                    let firstValue = loadAxles.indices.contains(firstIndex)
                    ? loadAxles[firstIndex] : 0
                    let secondValue = loadAxles.indices.contains(secondIndex)
                    ? loadAxles[secondIndex] : 0
                    if printViewModel.isOn(11) {
                        lines.append("\(rowIndex + 1)Axle : \(firstValue)kg / \(secondValue)kg")
                        lines.append("                      \(firstValue + secondValue)kg")
                    }
                    
                    if printViewModel.isOn(12) {
                        let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                        let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
                        let firstWeightIndex = firstIndex + 1
                        let secondWeightIndex = secondIndex + 1
                        
                        lines.append(
                            "Weight\(firstWeightIndex) : \(firstValue)kg (\(String(format: "%.1f", firstPercent))%)"
                        )
                        lines.append(
                            "Weight\(secondWeightIndex) : \(secondValue)kg (\(String(format: "%.1f", secondPercent))%)"
                        )
                    }
                }
                let count = loadAxles.count
                let half = count / 2
                
                let first = loadAxles.prefix(half).reduce(0, +)
                let second = loadAxles.dropFirst(half).reduce(0, +)
                
                if printViewModel.isOn(13) {
                    lines.append("1st Weight : \(first)kg")
                    lines.append("2st Weight : \(second)kg")
                    lines.append("Net Weight : \(first - second)kg")
                }
                
                
                lines.append(String(localized: "Line"))
                lines.append("Total : \(totalSum)kg")
                
                if printViewModel.isOn(14) {
                    lines.append("over : \(first - second)kg")
                }
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
            ? printViewModel.inspectorNameText ?? ""
            : "____________"
        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(17) { lines.append("Driver :         ____________") }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
        return lines
    }
    
    static func buildThird(
        weighting1st: Int,
        weighting2nd: Int,
        netWeight: Int,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        timeStamp: Date,
        item: String,
        client : String,
        vehicle : String,
        serialNumber: String,
        selectedType: Int
    )
    -> [String] {

        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if printViewModel.isOn(3) {
            let t = printViewModel.frmatter.string(from: timeStamp)
            lines.append(t)
        }

        if printViewModel.isOn(4) {
            let t = printViewModel.dateFormatter.string(from: timeStamp)
            lines.append("DATE : \(t)")
        }

        if printViewModel.isOn(5) {
            let t =  printViewModel.timeFormatter.string(from: timeStamp)
            lines.append("TIME : \(t)")
        }

        let itemCheck = if dataViewModel.productTitle == item { "N/A" } else { item }
        let clientCheck = if dataViewModel.clientTitle == client { "N/A" } else { client }
        let vehicleCheck = if vehicle.isEmpty { "N/A" } else { vehicle }
        
        if printViewModel.isOn(6) {
            lines.append("\(dataViewModel.productTitle ?? "Item") : \(itemCheck)")
        }

        if printViewModel.isOn(7) {
            lines.append("\(dataViewModel.clientTitle ?? "Client") : \(clientCheck)")
        }
        
        if printViewModel.isOn(8) { lines.append("S/N : \(serialNumber)") }
        if printViewModel.isOn(9) { lines.append("Vehicle : \(vehicleCheck)") }
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }

    // MARK: Load Axles
        
        lines.append("1st Weight : \(weighting1st)kg")
        lines.append("2st Weight : \(weighting2nd)kg")
        lines.append("Net Weight : \(netWeight)kg")
        lines.append(String(localized: "Line"))
        lines.append("Total : \(weighting1st+weighting2nd)kg")
        
        if printViewModel.isOn(14) {
            lines.append("over : \(weighting1st - weighting2nd)kg")
        }
        
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
            ? printViewModel.inspectorNameText ?? ""
            : "____________"
        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(17) { lines.append("Driver :         ____________") }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
        return lines
    }
    
    static func buildTwoStepRead(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {

        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if printViewModel.isOn(3) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.frmatter.string(from: $0)
            } ?? "N/A"
            lines.append(t)
        }

        if printViewModel.isOn(4) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.dateFormatter.string(from: $0)
            } ?? "N/A"
            lines.append("DATE : \(t)")
        }

        if printViewModel.isOn(5) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.timeFormatter.string(from: $0)
            } ?? "N/A"
            lines.append("TIME : \(t)")
        }

        if printViewModel.isOn(6) {
            lines.append("\(dataViewModel.productTitle ?? "Item") : \(loadAxleItem.product ?? "N/A")")
        }

        if printViewModel.isOn(7) {
            lines.append("\(dataViewModel.clientTitle ?? "Client") : \(loadAxleItem.client ?? "N/A")")
        }

        if printViewModel.isOn(8) { lines.append("S/N : \(loadAxleItem.serialNumber ?? "N/A")") }
        if printViewModel.isOn(9) { lines.append("Vehicle : \(loadAxleItem.vehicle ?? "N/A")") }
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }

        // MARK: Load Axles
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
            let weighting1st = loadAxles.first ?? 0
            let weighting2nd = loadAxles.last ?? 0
            let netWeight = weighting1st - weighting2nd
            let total = weighting1st + weighting2nd
            lines.append("1st Weight : \(weighting1st)kg")
            lines.append("2st Weight : \(weighting2nd)kg")
            lines.append("Net Weight : \(netWeight)kg")
            lines.append(String(localized: "Line"))
            lines.append("Total : \(total)kg")
            
            if printViewModel.isOn(14) {
                lines.append("over : \(netWeight)kg")
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
            ? printViewModel.inspectorNameText ?? ""
            : "____________"
        
        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(17) { lines.append("Driver :           ____________") }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")

        return lines
    }
    
    
    static func buildData(
        loadAxleInfos: [LoadAxleInfo],
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        onProgress: @escaping (_ current: Int, _ total: Int) -> Void
    ) -> [String] {

        var lines: [String] = []
        let totalCount = loadAxleInfos.count

        for (index, info) in loadAxleInfos.enumerated() {

            // 🔔 진행률 알림
            onProgress(index + 1, totalCount)

            if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
            if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
            if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }
                        
            if printViewModel.isOn(3) {
                let t = info.timestamp.map {
                    printViewModel.frmatter.string(from: $0)
                } ?? "N/A"
                lines.append(t)
            }

            if printViewModel.isOn(4) {
                let t = info.timestamp.map {
                    printViewModel.dateFormatter.string(from: $0)
                } ?? "N/A"
                lines.append("DATE : \(t)")
            }

            if printViewModel.isOn(5) {
                let t = info.timestamp.map {
                    printViewModel.timeFormatter.string(from: $0)
                } ?? "N/A"
                lines.append("TIME : \(t)")
            }

            if printViewModel.isOn(6) {
                lines.append("\(dataViewModel.productTitle ?? "Item") : \(info.product ?? "N/A")")
            }

            if printViewModel.isOn(7) {
                lines.append("\(dataViewModel.clientTitle ?? "Client") : \(info.client ?? "N/A")")
            }

            if printViewModel.isOn(8) { lines.append("S/N : \(info.serialNumber ?? "N/A")") }
            if printViewModel.isOn(9) { lines.append("Vehicle : \(info.vehicle ?? "N/A")") }
            if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
            
            // MARK: Load Axles
            if Int(info.weightNum ?? "0") == 2{
                if let data = info.loadAxleData,
                   let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
                    let weighting1st = loadAxles.first ?? 0
                    let weighting2nd = loadAxles.last ?? 0
                    let netWeight = weighting1st - weighting2nd
                    let total = weighting1st + weighting2nd
                    lines.append("1st Weight : \(weighting1st)kg")
                    lines.append("2st Weight : \(weighting2nd)kg")
                    lines.append("Net Weight : \(netWeight)kg")
                    lines.append(String(localized: "Line"))
                    lines.append("Total : \(total)kg")
                    
                    if printViewModel.isOn(14) {
                        lines.append("over : \(netWeight)kg")
                    }
                }
            } else {
                let loadAxles = decodeLoadAxleData(info.loadAxleData)
                let totalSum = loadAxles.reduce(0, +)
                let rowCount = (loadAxles.count + 1) / 2

                                for rowIndex in 0..<rowCount {
                                    let firstIndex = rowIndex * 2
                                    let secondIndex = firstIndex + 1

                                    let firstValue = loadAxles.indices.contains(firstIndex)
                                        ? loadAxles[firstIndex] : 0
                                    let secondValue = loadAxles.indices.contains(secondIndex)
                                        ? loadAxles[secondIndex] : 0

                                    if printViewModel.isOn(11) {
                                        lines.append("\(rowIndex + 1)Axle : \(firstValue)kg / \(secondValue)kg")
                                        lines.append("                      \(firstValue + secondValue)kg")
                                    }

                                    if printViewModel.isOn(12) {
                                        let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                                        let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0

                                        lines.append(
                                            "Weight\(firstIndex + 1) : \(firstValue)kg (\(String(format: "%.1f", firstPercent))%)"
                                        )
                                        lines.append(
                                            "Weight\(secondIndex + 1) : \(secondValue)kg (\(String(format: "%.1f", secondPercent))%)"
                                        )
                                    }
                                }

                                if printViewModel.isOn(13) {
                                    let half = loadAxles.count / 2
                                    let first = loadAxles.prefix(half).reduce(0, +)
                                    let second = loadAxles.dropFirst(half).reduce(0, +)

                                    lines.append("1st Weight : \(first)kg")
                                    lines.append("2st Weight : \(second)kg")
                                    lines.append("Net Weight : \(first - second)kg")
                                }

                                lines.append(String(localized: "Line"))
                                lines.append("Total : \(totalSum)kg")

                                if printViewModel.isOn(14) {
                                    lines.append("over : \(totalSum)kg")
                                }
            }
            
            let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
                ? printViewModel.inspectorNameText ?? ""
                : "____________"
            
            if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
            if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
            if printViewModel.isOn(17) { lines.append("Driver :           ____________") }
            lines.append("  ")
            lines.append("  ")
            lines.append("  ")
        }

        return lines
    }
    
    static func decodeLoadAxleData(_ data: Data?) -> [Int] {
        guard let data else { return [] }

        do {
            return try JSONDecoder().decode([Int].self, from: data)
        } catch {
            print("❌ loadAxleData decode 실패:", error)
            return []
        }
    }
    
    static func buildLines(
        info: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {

        var lines: [String] = []

        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }

        if let date = info.timestamp {
            if printViewModel.isOn(4) {
                lines.append("DATE : \(printViewModel.dateFormatter.string(from: date))")
            }
            if printViewModel.isOn(5) {
                lines.append("TIME : \(printViewModel.timeFormatter.string(from: date))")
            }
        }

        if printViewModel.isOn(6) {
            lines.append("\(dataViewModel.productTitle ?? "Item") : \(info.product ?? "N/A")")
        }

        if printViewModel.isOn(7) {
            lines.append("\(dataViewModel.clientTitle ?? "Client") : \(info.client ?? "N/A")")
        }

        if printViewModel.isOn(9) {
            lines.append("Vehicle : \(info.vehicle ?? "N/A")")
        }

        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        // MARK: Load Axles
        if Int(info.weightNum ?? "0") == 2{
            if let data = info.loadAxleData,
               let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
                let weighting1st = loadAxles.first ?? 0
                let weighting2nd = loadAxles.last ?? 0
                let netWeight = weighting1st - weighting2nd
                let total = weighting1st + weighting2nd
                lines.append("1st Weight : \(weighting1st)kg")
                lines.append("2st Weight : \(weighting2nd)kg")
                lines.append("Net Weight : \(netWeight)kg")
                lines.append(String(localized: "Line"))
                lines.append("Total : \(total)kg")
                
                if printViewModel.isOn(14) {
                    lines.append("over : \(netWeight)kg")
                }
            }
        } else {
            let loadAxles = decodeLoadAxleData(info.loadAxleData)
            let totalSum = loadAxles.reduce(0, +)
            let rowCount = (loadAxles.count + 1) / 2

            for rowIndex in 0..<rowCount {
                let firstIndex = rowIndex * 2
                let secondIndex = firstIndex + 1
                
                let firstValue = loadAxles.indices.contains(firstIndex)
                ? loadAxles[firstIndex] : 0
                let secondValue = loadAxles.indices.contains(secondIndex)
                ? loadAxles[secondIndex] : 0
                
                if printViewModel.isOn(11) {
                    lines.append("\(rowIndex + 1)Axle : \(firstValue)kg / \(secondValue)kg")
                    lines.append("                      \(firstValue + secondValue)kg")
                }
                
                if printViewModel.isOn(12) {
                    let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                    let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
                    
                    lines.append(
                        "Weight\(firstIndex + 1) : \(firstValue)kg (\(String(format: "%.1f", firstPercent))%)"
                    )
                    lines.append(
                        "Weight\(secondIndex + 1) : \(secondValue)kg (\(String(format: "%.1f", secondPercent))%)"
                    )
                }
            }

            if printViewModel.isOn(13) {
                let half = loadAxles.count / 2
                let first = loadAxles.prefix(half).reduce(0, +)
                let second = loadAxles.dropFirst(half).reduce(0, +)
                
                lines.append("1st Weight : \(first)kg")
                lines.append("2st Weight : \(second)kg")
                lines.append("Net Weight : \(first - second)kg")
            }

                            lines.append(String(localized: "Line"))
                            lines.append("Total : \(totalSum)kg")

            if printViewModel.isOn(14) {
                lines.append("over : \(totalSum)kg")
            }
        }

        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
            ? printViewModel.inspectorNameText ?? ""
            : "____________"
        if printViewModel.isOn(15) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(16) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(17) { lines.append("Driver :         ____________") }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")

        return lines
    }
}
