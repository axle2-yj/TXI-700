//
//  PrintForm.swift
//  TXI-700
//
//  Created by 서용준 on 12/16/25.
//

import SwiftUI
import Foundation

struct PrintLineBuilder {
    // MARK: - Data Detail Sceen One Step Read Form
    static func buildRead(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
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
            lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("DATE"), ":", t))
        }
        
        if printViewModel.isOn(5) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.timeFormatter.string(from: $0)
            } ?? "N/A"
            lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("TIME"), ":", t))
        }
        
        let productTitle = (dataViewModel.productTitle != nil)
            ? lang.localized(dataViewModel.productTitle!)
            : lang.localized("Item")
        let clientTitle = (dataViewModel.clientTitle != nil)
            ? lang.localized(dataViewModel.clientTitle!)
            : lang.localized("Client")
        
        if printViewModel.isOn(6) {
            lines.append(CommonPrintFormatter.threeColumnLine(productTitle, ":", loadAxleItem.product ?? "N/A"))
        }
        
        if printViewModel.isOn(7) {
            lines.append(CommonPrintFormatter.threeColumnLine(clientTitle, ":", loadAxleItem.client ?? "N/A"))
        }
        
        if printViewModel.isOn(8) {
            lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("S/N"), ":", loadAxleItem.serialNumber ?? "N/A"))
        }
        if printViewModel.isOn(9) {
            lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("Vehicle"), ":", loadAxleItem.vehicle ?? "N/A"))
        }
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
                    lines.append(CommonPrintFormatter.threeColumnLine("\(rowIndex + 1)\(lang.localized("Axle"))", ":", "\(firstValue)kg/\(secondValue)kg"))

                    lines.append(CommonPrintFormatter.oneColRowRead("\(firstValue + secondValue)kg"))

                }
                
                if printViewModel.isOn(12) {
                    let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                    let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
                    let firstWeightIndex = firstIndex + 1
                    let secondWeightIndex = secondIndex + 1
                    
                    lines.append(CommonPrintFormatter.threeColumnLine("\(lang.localized("Weight"))\(firstWeightIndex)", ":", "\(firstValue)kg (\(String(format: "%.1f", firstPercent))%)")
                    )
                    lines.append(CommonPrintFormatter.threeColumnLine("\(lang.localized("Weight"))\(secondWeightIndex)", ":", "\(secondValue)kg (\(String(format: "%.1f", secondPercent))%)")
                    )
                }
            }
            
            let count = loadAxles.count
            let half = count / 2
            
            let first = loadAxles.prefix(half).reduce(0, +)
            let second = loadAxles.dropFirst(half).reduce(0, +)
            let left = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 0 }
                .map { $0.element }
                .reduce(0, +)

            let right = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 1 }
                .map { $0.element }
                .reduce(0, +)
            
            if printViewModel.isOn(13) {
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("1stWeight"), ":", "\(first)kg"))
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("2stWeight"), ":", "\(second)kg"))
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("NetWeight"), ":", "\(first - second)kg"))
            }
            
            lines.append(String(localized: "Line"))
            lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("Total"), ":", "\(totalSum)kg"))

            
            if printViewModel.isOn(14) {
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("over"), ":", "\(second-first)kg"))
            }
            
            if printViewModel.isOn(15) {
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("left"), ":", "\(left)kg"))
            }
            
            if printViewModel.isOn(16) {
                lines.append(CommonPrintFormatter.threeColumnLine(lang.localized("right"), ":", "\(right)kg"))
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "------------"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndInspector(inspector) )
            
        }
        if printViewModel.isOn(19) {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndInspector("------------") )
        }
        return lines
    }
    
    // MARK: - Data Detail Sceen One Step Print Form
    static func buildPrint(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
    ) -> [String] {
        
        var lines: [String] = []
        
        lines.append("  ")
        lines.append("  ")
        
        if printViewModel.isOn(0) { lines.append( String(localized: "Line") )}
        if printViewModel.isOn(1) { lines.append( CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? "Print Head Line") )}
        if printViewModel.isOn(2) { lines.append( String(localized: "Line") )}
        
        if printViewModel.isOn(3) {
            let dt = loadAxleItem.timestamp.map {
                printViewModel.frmatter.string(from: $0)
            } ?? "N/A"
            lines.append( CommonPrintFormatter.fullRow(dt) )
        }
        
        if printViewModel.isOn(4) {
            let d = loadAxleItem.timestamp.map {
                printViewModel.dateFormatter.string(from: $0)
            } ?? "N/A"
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
        }
        
        if printViewModel.isOn(5) {
            let t = loadAxleItem.timestamp.map {
                printViewModel.timeFormatter.string(from: $0)
            } ?? "N/A"
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":",t) )
        }
        let productTitle = (dataViewModel.productTitle != nil)
            ? lang.localized(dataViewModel.productTitle!)
            : lang.localized("Item")
        let clientTitle = (dataViewModel.clientTitle != nil)
            ? lang.localized(dataViewModel.clientTitle!)
            : lang.localized("Client")
        
        if printViewModel.isOn(6) {lines.append(
            CommonPrintFormatter.threeColRowLift(productTitle, ":", loadAxleItem.product ?? "N/A") )}
        
        if printViewModel.isOn(7) { lines.append(
            CommonPrintFormatter.threeColRowLift(clientTitle, ":", loadAxleItem.client ?? "N/A") )}
        
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", loadAxleItem.serialNumber ?? "N/A") )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", loadAxleItem.vehicle ?? "N/A") )}
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
                    lines.append( CommonPrintFormatter.fiveColRow("\(rowIndex + 1)" + lang.localized("Axle"), ":", "\(firstValue)kg", "/", " \(secondValue)kg") )
                    lines.append( CommonPrintFormatter.oneColRowEnd("\(firstValue + secondValue)kg") )
                }
                
                if printViewModel.isOn(12) {
                    let firstPercent = totalSum > 0 ? Double(firstValue) / Double(totalSum) * 100 : 0
                    let secondPercent = totalSum > 0 ? Double(secondValue) / Double(totalSum) * 100 : 0
                    let firstWeightIndex = firstIndex + 1
                    let secondWeightIndex = secondIndex + 1
                    
                    lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Weight")+"\(firstWeightIndex)", ":", "\(firstValue)kg (\(String(format: "%.1f", firstPercent))%)") )
                    lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Weight")+"\(secondWeightIndex)", ":", "\(secondValue)kg (\(String(format: "%.1f", secondPercent))%)"))
                }
            }
            
            let count = loadAxles.count
            let half = count / 2
            
            let first = loadAxles.prefix(half).reduce(0, +)
            let second = loadAxles.dropFirst(half).reduce(0, +)
            let left = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 0 }
                .map { $0.element }
                .reduce(0, +)

            let right = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 1 }
                .map { $0.element }
                .reduce(0, +)
            
            if printViewModel.isOn(13) {
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("1stWeight"), ":", "\(first)kg") )
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("2stWeight"), ":", "\(second)kg") )
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("NetWeight"), ":", "\(first - second)kg") )
            }
            
            lines.append( String(localized: "Line"))
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Total"), ":", "\(totalSum)kg") )
            
            if printViewModel.isOn(14) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(totalSum)kg") )}
            
            if printViewModel.isOn(15) { lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("leftWeight"), ":", "\(left)kg") )}
            
            if printViewModel.isOn(16) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("rightWeight"), ":", "\(right)kg") )}
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "------------"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndInspector(inspector) )
            
        }
        if printViewModel.isOn(19) {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndInspector("------------") )
        }
        lines.append("  ")
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
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
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
                    let firstValue = loadAxles.indices.contains(firstIndex) ? loadAxles[firstIndex] : 0
                    let secondValue = loadAxles.indices.contains(secondIndex) ? loadAxles[secondIndex] : 0
                    if printViewModel.isOn(11) {
                        lines.append(
    //                        "\(rowIndex + 1)Axle : \(firstValue)kg/ \(secondValue)kg"
                            CommonPrintFormatter.fiveColRow("\(rowIndex + 1)Axle", ":", "\(firstValue)kg", "/", " \(secondValue)kg")
                        )
                        
                        lines.append(
    //                        "                     \(firstValue + secondValue)kg"
                            CommonPrintFormatter.oneColRowEnd("\(firstValue + secondValue)kg")
                        )
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
                let left = loadAxles
                    .enumerated()
                    .filter { $0.offset % 2 == 0 }
                    .map { $0.element }
                    .reduce(0, +)

                let right = loadAxles
                    .enumerated()
                    .filter { $0.offset % 2 == 1 }
                    .map { $0.element }
                    .reduce(0, +)
                
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
                
                if printViewModel.isOn(15) {
                    lines.append("over : \(left)kg")
                }
                
                if printViewModel.isOn(16) {
                    lines.append("over : \(right)kg")
                }
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "____________"
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append("  ")
            lines.append("Inspector :     \(inspector)")
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append("  ")
            lines.append("Driver :        ____________")
        }
        lines.append("  ")
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
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
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
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append("  ")
            lines.append("Inspector :     \(inspector)")
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append("  ")
            lines.append("Driver :        ____________")
        }
        lines.append("  ")
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
            let left = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 0 }
                .map { $0.element }
                .reduce(0, +)

            let right = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 1 }
                .map { $0.element }
                .reduce(0, +)
            
            lines.append("1st Weight : \(weighting1st)kg")
            lines.append("2st Weight : \(weighting2nd)kg")
            lines.append("Net Weight : \(netWeight)kg")
            lines.append(String(localized: "Line"))
            lines.append("Total : \(total)kg")
            
            if printViewModel.isOn(14) {
                lines.append("over : \(netWeight)kg")
            }
            if printViewModel.isOn(15) {
                lines.append("left : \(left)kg")
            }
            
            if printViewModel.isOn(16) {
                lines.append("right : \(right)kg")
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "____________"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append("  ")
            lines.append("Inspector :     \(inspector)")
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append("  ")
            lines.append("Driver :           ____________")
        }
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    static func buildTwoStepPrint(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {
        
        var lines: [String] = []
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
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
            let left = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 0 }
                .map { $0.element }
                .reduce(0, +)

            let right = loadAxles
                .enumerated()
                .filter { $0.offset % 2 == 1 }
                .map { $0.element }
                .reduce(0, +)
            
            lines.append("1st Weight : \(weighting1st)kg")
            lines.append("2st Weight : \(weighting2nd)kg")
            lines.append("Net Weight : \(netWeight)kg")
            lines.append(String(localized: "Line"))
            lines.append("Total : \(total)kg")
            
            if printViewModel.isOn(14) {
                lines.append("over : \(netWeight)kg")
            }
            if printViewModel.isOn(15) {
                lines.append("left : \(left)kg")
            }
            
            if printViewModel.isOn(16) {
                lines.append("right : \(right)kg")
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "____________"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) {
            lines.append("  ")
            lines.append("Inspector :     \(inspector)")
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append("  ")
            lines.append("Driver :        ____________")
        }
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
            
            lines.append("  ")
            lines.append("  ")
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
                    let left = loadAxles
                        .enumerated()
                        .filter { $0.offset % 2 == 0 }
                        .map { $0.element }
                        .reduce(0, +)

                    let right = loadAxles
                        .enumerated()
                        .filter { $0.offset % 2 == 1 }
                        .map { $0.element }
                        .reduce(0, +)
                    
                    lines.append("1st Weight : \(weighting1st)kg")
                    lines.append("2st Weight : \(weighting2nd)kg")
                    lines.append("Net Weight : \(netWeight)kg")
                    lines.append(String(localized: "Line"))
                    lines.append("Total : \(total)kg")
                    
                    if printViewModel.isOn(14) {
                        lines.append("over : \(netWeight)kg")
                    }
                    if printViewModel.isOn(15) {
                        lines.append("left : \(left)kg")
                    }
                    
                    if printViewModel.isOn(16) {
                        lines.append("right : \(right)kg")
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
                        lines.append(
    //                        "\(rowIndex + 1)Axle : \(firstValue)kg/ \(secondValue)kg"
                            CommonPrintFormatter.fiveColRow("\(rowIndex + 1)Axle", ":", "\(firstValue)kg", "/", " \(secondValue)kg")
                        )
                        
                        lines.append(
    //                        "                     \(firstValue + secondValue)kg"
                            CommonPrintFormatter.oneColRowEnd("\(firstValue + secondValue)kg")
                        )
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
            
            if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
            if printViewModel.isOn(18) { lines.append("Inspector :     \(inspector)") }
            if printViewModel.isOn(19) { lines.append("Driver :        ____________") }
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
        lines.append("  ")
        lines.append("  ")
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
                    lines.append(
//                        "\(rowIndex + 1)Axle : \(firstValue)kg/ \(secondValue)kg"
                        CommonPrintFormatter.fiveColRow("\(rowIndex + 1)Axle", ":", "\(firstValue)kg", "/", " \(secondValue)kg")
                    )
                    
                    lines.append(
//                        "                     \(firstValue + secondValue)kg"
                        CommonPrintFormatter.oneColRowEnd("\(firstValue + secondValue)kg")
                    )
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
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(18) { lines.append("Inspector :     \(inspector)") }
        if printViewModel.isOn(19) { lines.append("Driver :         ____________") }
        lines.append("  ")
        lines.append("  ")
        
        return lines
    }
    
    static func buildBalanceLines(
        axleState: [Int: AxleState],
        timeStamp: Date,
        client : String,
        vehicle : String,
        serialNumber: String,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {
        
        var lines: [String] = []
        let left1 = axleState[1]?.leftWeight ?? 0
        let left2 = axleState[2]?.leftWeight ?? 0
        let left3 = axleState[3]?.leftWeight ?? 0
        let left4 = axleState[5]?.leftWeight ?? 0
        let right1 = axleState[1]?.rightWeight ?? 0
        let right2 = axleState[2]?.rightWeight ?? 0
        let right3 = axleState[3]?.rightWeight ?? 0
        let right4 = axleState[5]?.rightWeight ?? 0
        
        let axle3 = (left3 != 0 || right3 != 0) ? left3 + right3 : 0
        let axle4 = (left4 != 0 || right4 != 0) ? left4 + right4 : 0
        
        let lefts  = [left1, left2, left3, left4]
        let rights = [right1, right2, right3, right4]
        
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
        
        lines.append("  ")
        lines.append("  ")
        
        lines.append(String(localized: "Line"))
        lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? ""))
        lines.append(String(localized: "Line"))
        
        let t = printViewModel.frmatter.string(from: timeStamp)
        lines.append(CommonPrintFormatter.twoColBasicRow("Date", t))
        lines.append(CommonPrintFormatter.twoColBasicRow("Client", client))
        lines.append(CommonPrintFormatter.twoColBasicRow("Vehicle", vehicle))
        lines.append(CommonPrintFormatter.twoColBasicRow("S/N", serialNumber))
        lines.append(String(localized: "Line"))
        if left4 != 0 || right4 != 0 {
            lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left4)kg ", left4Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right4)kg ", right4Ratio))
        } else if left3 != 0 || right3 != 0 {
            lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
        } else {
            lines.append(CommonPrintFormatter.twoColAlignedRow("LF", "\(left1)kg ", left1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RF", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LR", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RR", "\(right2)kg ", right2Ratio))
        }
        lines.append(CommonPrintFormatter.twoColAlignedRow("FRONT", "\(front)kg ", frontRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("REAR", "\(rear)kg ", rearRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("LT SUM", "\(ltSum)kg ", leftRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("RT SUM", "\(rtSum)kg ", rightRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("LF/RR", "\(result.lfRr)kg ", lfRrRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("RF/LR", "\(result.rfLr)kg ", rfLrRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("TOTAL", "\(total)kg ", 0.0))
        lines.append(String(localized: "Line"))
        
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? "\(String(describing: printViewModel.inspectorNameText))" : "____________"
        
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Inspector", "\(inspector)  "))
        lines.append("  ")
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Driver", "____________  "))
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    static func buildBalanceRead(
        loadAxleItem: LoadAxleInfo,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {
        var lines: [String] = []
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
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
            
            let timeStamp = loadAxleItem.timestamp!
            let client = loadAxleItem.client ?? "N/A"
            let vehicle = loadAxleItem.vehicle ?? "N/A"
            let serialNumber = loadAxleItem.serialNumber ?? "N/A"
            
            
            lines.append(String(localized: "Line"))
            lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? ""))
            lines.append(String(localized: "Line"))
            
            let t = printViewModel.frmatter.string(from: timeStamp)
            lines.append(CommonPrintFormatter.twoColBasicRow("Date", t))
            lines.append(CommonPrintFormatter.twoColBasicRow("Client", client))
            lines.append(CommonPrintFormatter.twoColBasicRow("Vehicle", vehicle))
            lines.append(CommonPrintFormatter.twoColBasicRow("S/N", serialNumber))
            lines.append(String(localized: "Line"))
            if left4 != 0 || right4 != 0 {
                lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left4)kg ", left4Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right4)kg ", right4Ratio))
            } else if left3 != 0 || right3 != 0 {
                lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
            } else {
                lines.append(CommonPrintFormatter.twoColAlignedRow("LF", "\(left1)kg ", left1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("RF", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("LR", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("RR", "\(right2)kg ", right2Ratio))
            }
            lines.append(CommonPrintFormatter.twoColAlignedRow("FRONT", "\(front)kg ", frontRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("REAR", "\(rear)kg ", rearRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LT SUM", "\(ltSum)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RT SUM", "\(rtSum)kg ", rightRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LF/RR", "\(result.lfRr)kg ", lfRrRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RF/LR", "\(result.rfLr)kg ", rfLrRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("TOTAL", "\(total)kg ", 0.0))
            lines.append(String(localized: "Line"))
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? "\(String(describing: printViewModel.inspectorNameText))" : "____________"
        
        lines.append(CommonPrintFormatter.twoColRow("Inspector", "\(inspector)  "))
        lines.append(CommonPrintFormatter.twoColRow("Driver", "____________  "))
        return lines
    }
    
    static func buildBalanceDataPrintLine(
        loadAxleItem: LoadAxleInfo,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {
        var lines: [String] = []
        lines.append("  ")
        lines.append("  ")
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
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
            
            let timeStamp = loadAxleItem.timestamp!
            let client = loadAxleItem.client ?? "N/A"
            let vehicle = loadAxleItem.vehicle ?? "N/A"
            let serialNumber = loadAxleItem.serialNumber ?? "N/A"
            
            lines.append(String(localized: "Line"))
            lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? ""))
            lines.append(String(localized: "Line"))
            
            let t = printViewModel.frmatter.string(from: timeStamp)
            lines.append(CommonPrintFormatter.twoColBasicRow("Date", t))
            lines.append(CommonPrintFormatter.twoColBasicRow("Client", client))
            lines.append(CommonPrintFormatter.twoColBasicRow("Vehicle", vehicle))
            lines.append(CommonPrintFormatter.twoColBasicRow("S/N", serialNumber))
            lines.append(String(localized: "Line"))
            if left4 != 0 || right4 != 0 {
                lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left4)kg ", left4Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right4)kg ", right4Ratio))
            } else if left3 != 0 || right3 != 0 {
                lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
            } else {
                lines.append(CommonPrintFormatter.twoColAlignedRow("LF", "\(left1)kg ", left1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("RF", "\(right1)kg ", right1Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("LR", "\(left2)kg ", left2Ratio))
                lines.append(CommonPrintFormatter.twoColAlignedRow("RR", "\(right2)kg ", right2Ratio))
            }
            lines.append(CommonPrintFormatter.twoColAlignedRow("FRONT", "\(front)kg ", frontRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("REAR", "\(rear)kg ", rearRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LT SUM", "\(ltSum)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RT SUM", "\(rtSum)kg ", rightRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LF/RR", "\(result.lfRr)kg ", lfRrRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RF/LR", "\(result.rfLr)kg ", rfLrRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("TOTAL", "\(total)kg ", 0.0))
            lines.append(String(localized: "Line"))
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? "\(String(describing: printViewModel.inspectorNameText))" : "____________"
        
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Inspector", "\(inspector)  "))
        lines.append("  ")
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Driver", "____________  "))
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    static func buildBalanceLines(
        left1: Int,
        left2: Int,
        left3: Int,
        left4: Int,
        right1: Int,
        right2: Int,
        right3: Int,
        right4: Int,
        timeStamp: Date,
        client : String,
        vehicle : String,
        serialNumber: String,
        printViewModel: PrintFormSettingViewModel
    ) -> [String] {
        
        var lines: [String] = []
        let axle3 = (left3 != 0 || right3 != 0) ? left3 + right3 : 0
        let axle4 = (left4 != 0 || right4 != 0) ? left4 + right4 : 0
        let lefts  = [left1, left2, left3, left4]
        let rights = [right1, right2, right3, right4]
        let lfRr = zip(lefts, rights.dropFirst()).reduce(0) { $0 + $1.0 + $1.1 }
        let rfLr = zip(rights, lefts.dropFirst()).reduce(0) { $0 + $1.0 + $1.1 }
        
        let front = left1 + right1
        let rear = left2 + right2 + axle3 + axle4
        let ltSum = lefts.reduce(0, +)
        let rtSum = rights.reduce(0, +)
        let total = front + rear
        
        let leftRatio: Double = Double(ltSum) / Double(total) * 100
        let rightRatio: Double = Double(rtSum) / Double(total) * 100
        let frontRatio: Double = Double(front) / Double(total) * 100
        let rearRatio: Double = Double(rear) / Double(total) * 100
        let lfRrRatio: Double = Double(lfRr) / Double(total) * 100
        let rfLrRatio: Double = Double(rfLr) / Double(total) * 100
        let left1Ratio: Double = Double(left1) / Double(total) * 100
        let right1Ratio: Double = Double(right1) / Double(total) * 100
        let left2Ratio: Double = Double(left2) / Double(total) * 100
        let right2Ratio: Double = Double(right2) / Double(total) * 100
        let left3Ratio: Double = Double(left3) / Double(total) * 100
        let right3Ratio: Double = Double(right3) / Double(total) * 100
        let left4Ratio: Double = Double(left4) / Double(total) * 100
        let right4Ratio: Double = Double(right4) / Double(total) * 100
        
        lines.append("  ")
        lines.append("  ")
        
        lines.append(String(localized: "Line"))
        lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? ""))
        lines.append(String(localized: "Line"))
        
        let t = printViewModel.frmatter.string(from: timeStamp)
        lines.append(CommonPrintFormatter.twoColBasicRow("Date", t))
        lines.append(CommonPrintFormatter.twoColBasicRow("Client", client))
        lines.append(CommonPrintFormatter.twoColBasicRow("Vehicle", vehicle))
        lines.append(CommonPrintFormatter.twoColBasicRow("S/N", serialNumber))
        lines.append(String(localized: "Line"))
        if left4 != 0 || right4 != 0 {
            lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left4)kg ", left4Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right4)kg ", right4Ratio))
        } else if left3 != 0 || right3 != 0 {
            lines.append(CommonPrintFormatter.twoColAlignedRow("L1", "\(left1)kg ", leftRatio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R1", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L2", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R2", "\(right2)kg ", right2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("L3", "\(left3)kg ", left3Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("R3", "\(right3)kg ", right3Ratio))
        } else {
            lines.append(CommonPrintFormatter.twoColAlignedRow("LF", "\(left1)kg ", left1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RF", "\(right1)kg ", right1Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("LR", "\(left2)kg ", left2Ratio))
            lines.append(CommonPrintFormatter.twoColAlignedRow("RR", "\(right2)kg ", right2Ratio))
        }
        lines.append(CommonPrintFormatter.twoColAlignedRow("FRONT", "\(front)kg ", frontRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("REAR", "\(rear)kg ", rearRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("LT SUM", "\(ltSum)kg ", leftRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("RT SUM", "\(rtSum)kg ", rightRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("LF/RR", "\(lfRr)kg ", lfRrRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("RF/LR", "\(rfLr)kg ", rfLrRatio))
        lines.append(CommonPrintFormatter.twoColAlignedRow("TOTAL", "\(total)kg ", 0.0))
        lines.append(String(localized: "Line"))
        
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? "\(String(describing: printViewModel.inspectorNameText))" : "____________"
        
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Inspector", "\(inspector)  "))
        lines.append("  ")
        lines.append("  ")
        lines.append(CommonPrintFormatter.twoColRow("Driver", "____________  "))
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
}

