//
//  PrintForm.swift
//  TXI-700
//
//  Created by 서용준 on 12/16/25.
//

import SwiftUI
import Foundation

struct PrintLineBuilder {
    
    // MARK: - Data Detail Sceen One Step Print Form
    
    static func buildPrintOneStepLineData(
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
        
        if printViewModel.isOn(6) {lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", loadAxleItem.product ?? "N/A") )}
        
        if printViewModel.isOn(7) { lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", loadAxleItem.client ?? "N/A") )}
        
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", loadAxleItem.serialNumber ?? "N/A") )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", loadAxleItem.vehicle ?? "N/A") )}
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        // MARK: Load Axles
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
            let rowCount = (loadAxles.count + 1) / 2
            let totalSum = loadAxles.reduce(0, +)
            let over = printViewModel.overValue - totalSum
            let overWeight = over < 0 ? over : 0

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
            
            if printViewModel.isOn(14) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(overWeight)kg") )}
            
            if printViewModel.isOn(15) { lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("leftWeight"), ":", "\(left)kg") )}
            
            if printViewModel.isOn(16) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("rightWeight"), ":", "\(right)kg") )}
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "------------"
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        lines.append("  ")
        if printViewModel.isOn(18) {
            if printViewModel.inspectorNameText?.isEmpty == false {
                lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
            } else {
                lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
                lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
            }
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    // MARK: - MainScreen Sceen One Step Print Form

    static func buildPrintOneStepLineMain(
        loadAxleItem: [LoadAxleStatus],
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        timeStamp: Date,
        item: String,
        client : String,
        vehicle : String,
        serialNumber: String,
        selectedType: Int,
        lang: LanguageManager
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
            let dt = printViewModel.frmatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.fullRow(dt) )
        }
        
        if printViewModel.isOn(4) {
            let d = printViewModel.dateFormatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
        }
        
        if printViewModel.isOn(5) {
            let t =  printViewModel.timeFormatter.string(from: timeStamp)
            lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":", t))
        }
        
        let itemCheck = if dataViewModel.productTitle == item { "N/A" } else { item }
        let clientCheck = if dataViewModel.clientTitle == client { "N/A" } else { client }
        let vehicleCheck = if vehicle.isEmpty { "N/A" } else { vehicle }
        
        if printViewModel.isOn(6) {lines.append( CommonPrintFormatter.threeColRowLift("\(dataViewModel.productTitle ?? "Item")", ":", itemCheck) )}
        if printViewModel.isOn(7) { lines.append( CommonPrintFormatter.threeColRowLift("\(dataViewModel.clientTitle ?? "Client")", ":", clientCheck) )}
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", serialNumber) )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", vehicleCheck) )}
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        // MARK: Load Axles
        if !loadAxleItem.isEmpty{
            for axleStatus in loadAxleItem {
                
                let loadAxles = axleStatus.loadAxlesData
                let totalSum = axleStatus.total
                let over = printViewModel.overValue - totalSum
                let overWeight = over < 0 ? over : 0
                let rowCount = (loadAxles.count + 1) / 2
                
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
                
                
                lines.append( String(localized: "Line") )
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Total"), ":", "\(totalSum)kg") )

                if printViewModel.isOn(14) {
                    lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(overWeight)kg") )
                }
                if printViewModel.isOn(15) {
                    lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("leftWeight"), ":", "\(left)kg") )
                }
                
                if printViewModel.isOn(16) {
                    lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("rightWeight"), ":", "\(right)kg") )
                }
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "------------"
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        lines.append("  ")
        if printViewModel.isOn(18) {
            if printViewModel.inspectorNameText?.isEmpty == false {
                lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
            } else {
                lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
                lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
            }
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
        return lines
    }
    
    // MARK: - MainScreen Sceen Two Step Print Form

    static func buildPrintTwoStepLineMain(
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
        selectedType: Int,
        lang: LanguageManager
    )
    -> [String] {
        
        var lines: [String] = []
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append( CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? "Print Head Line") )}
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }
        
        if printViewModel.isOn(3) {
            let dt = printViewModel.frmatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.fullRow(dt) )
        }
        
        if printViewModel.isOn(4) {
            let d = printViewModel.dateFormatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
        }
        
        if printViewModel.isOn(5) {
            let t =  printViewModel.timeFormatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":",t) )
        }
        
        let productTitle = (dataViewModel.productTitle != nil)
            ? lang.localized(dataViewModel.productTitle!)
            : lang.localized("Item")
        let clientTitle = (dataViewModel.clientTitle != nil)
            ? lang.localized(dataViewModel.clientTitle!)
            : lang.localized("Client")
        let itemCheck = if dataViewModel.productTitle == item { "N/A" } else { item }
        let clientCheck = if dataViewModel.clientTitle == client { "N/A" } else { client }
        let vehicleCheck = if vehicle.isEmpty { "N/A" } else { vehicle }
        let overWeight = printViewModel.overValue - (weighting1st+weighting2nd)
        
        if printViewModel.isOn(6) {lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", itemCheck) )}
        if printViewModel.isOn(7) { lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", clientCheck) )}
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", serialNumber) )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", vehicleCheck) )}
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        
        // MARK: Load Axles
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("1stWeight"), ":", "\(weighting1st)kg") )
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("2stWeight"), ":", "\(weighting2nd)kg") )
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("NetWeight"), ":", "\(netWeight)kg") )
        lines.append( String(localized: "Line") )
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Total"), ":", "\(weighting1st+weighting2nd)kg") )
        
        if printViewModel.isOn(14) {
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(overWeight)kg") )
        }
        
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText ?? ""
        : "------------"
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        lines.append("  ")
        if printViewModel.isOn(18) {
            if printViewModel.inspectorNameText?.isEmpty == false {
                lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
            } else {
                lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
                lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector))
            }
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
        
    // MARK: - Data Detail Sceen Two Step Print Form

    static func buildPrintTwoStepLineData(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
    ) -> [String] {
        
        var lines: [String] = []
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        if printViewModel.isOn(0) { lines.append( String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append( CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? "Print Head Line") )}
        if printViewModel.isOn(2) { lines.append( String(localized: "Line")) }
        
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
        
        if printViewModel.isOn(6) {lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", "\(loadAxleItem.product ?? "N/A")") )}
        
        
        if printViewModel.isOn(7) { lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", "\(loadAxleItem.client ?? "N/A")") )}
        
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", "\(loadAxleItem.serialNumber ?? "N/A")") )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", "\(loadAxleItem.vehicle ?? "N/A")") )}
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        // MARK: Load Axles
        if let data = loadAxleItem.loadAxleData,
           let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
            let weighting1st = loadAxles.first ?? 0
            let weighting2nd = loadAxles.last ?? 0
            let netWeight = weighting1st - weighting2nd
            let total = weighting1st + weighting2nd
            let over = printViewModel.overValue - total
            let overWeight = over < 0 ? over : 0
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
            
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("1stWeight"), ":", "\(weighting1st)kg") )
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("2stWeight"), ":", "\(weighting2nd)kg") )
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("NetWeight"), ":", "\(netWeight)kg") )
            lines.append( String(localized: "Line") )
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Total"), ":", "\(total)kg") )
            
            if printViewModel.isOn(14) {
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(overWeight)kg") )
            }
            if printViewModel.isOn(15) {
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("leftWeight"), ":", "\(left)kg") )
            }
            
            if printViewModel.isOn(16) {
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("rightWeight"), ":", "\(right)kg") )
            }
        }
        let inspector = (printViewModel.inspectorNameText?.isEmpty == false)
        ? printViewModel.inspectorNameText! + "     "
        : "------------"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        lines.append("  ")
        if printViewModel.isOn(18) {
            if printViewModel.inspectorNameText?.isEmpty == false {
                lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
            } else {
                lines.append("  ")
                lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
                lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
            }
        }
        if printViewModel.isOn(19) {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        }
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    // MARK: - PrintButton Print Form
    static func buildPrintLinesPrinter(
        info: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
    ) -> [String] {
        
        var lines: [String] = []
        
        lines.append("  ")
        lines.append("  ")
        
        if printViewModel.isOn(0) { lines.append(String(localized: "Line")) }
        if printViewModel.isOn(1) { lines.append(printViewModel.printHeadLineText ?? "Print Head Line") }
        if printViewModel.isOn(2) { lines.append(String(localized: "Line")) }
        
        if let date = info.timestamp {
            if printViewModel.isOn(3) {
                let dt = printViewModel.frmatter.string(from: date)
                lines.append( CommonPrintFormatter.fullRow(dt) )
            }
            if printViewModel.isOn(4) {
                let d = printViewModel.dateFormatter.string(from: date)
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
            }
            if printViewModel.isOn(5) {
                let t =  printViewModel.timeFormatter.string(from: date)
                lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":", t))

            }
        }
        
        if printViewModel.isOn(3) {
            let dt = info.timestamp.map {
                printViewModel.frmatter.string(from: $0)
            } ?? "N/A"
            lines.append( CommonPrintFormatter.fullRow(dt) )
        }
        
        if printViewModel.isOn(4) {
            let d = info.timestamp.map {
                printViewModel.dateFormatter.string(from: $0)
            } ?? "N/A"
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
        }
        
        if printViewModel.isOn(5) {
            let t = info.timestamp.map {
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
        
        if printViewModel.isOn(6) {lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", info.product ?? "N/A") )}
        
        if printViewModel.isOn(7) { lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", info.client ?? "N/A") )}
        
        if printViewModel.isOn(8) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", info.serialNumber ?? "N/A") )}
        if printViewModel.isOn(9) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", info.vehicle ?? "N/A") )}
        if printViewModel.isOn(10) { lines.append(String(localized: "Line")) }
        
        // MARK: Load Axles
        if Int(info.weightNum ?? "0") == 2{
            if let data = info.loadAxleData,
               let loadAxles = try? JSONDecoder().decode([Int].self, from: data) {
                let weighting1st = loadAxles.first ?? 0
                let weighting2nd = loadAxles.last ?? 0
                let netWeight = weighting1st - weighting2nd
                let total = weighting1st + weighting2nd
                let over = printViewModel.overValue - total
                let overWeight = over < 0 ? over : 0
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
                
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("1stWeight"), ":", "\(weighting1st)kg") )
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("2stWeight"), ":", "\(weighting2nd)kg") )
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("NetWeight"), ":", "\(netWeight)kg") )
                lines.append(String(localized: "Line"))
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Total"), ":", "\(total)kg") )

                if printViewModel.isOn(14) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("OverWeight"), ":", "\(overWeight)kg") )}
                
                if printViewModel.isOn(15) { lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("leftWeight"), ":", "\(left)kg") )}
                
                if printViewModel.isOn(16) { lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("rightWeight"), ":", "\(right)kg") )}
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
        ? printViewModel.inspectorNameText! + "     " : "------------"
        
        if printViewModel.isOn(17) { lines.append(String(localized: "Line")) }
        lines.append("  ")
        if printViewModel.isOn(18) {
            if printViewModel.inspectorNameText?.isEmpty == false {
                lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
            } else {
                lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
                lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
            }
        }
        if printViewModel.isOn(19) {
            lines.append("  ")
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        }
        
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        
        return lines
    }
    
    // MARK: - Main Sceen Balance Print Form

    static func buildPrintBalanceLinesMain(
        axleState: [Int: AxleState],
        timeStamp: Date,
        product: String,
        client : String,
        vehicle : String,
        serialNumber: String,
        dataViewModel : DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
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
        
//        let productTitle = (dataViewModel.productTitle != nil)
//            ? lang.localized(dataViewModel.productTitle!)
//            : lang.localized("Item")
//        let clientTitle = (dataViewModel.clientTitle != nil)
//            ? lang.localized(dataViewModel.clientTitle!)
//            : lang.localized("Client")
        
        lines.append("  ")
        lines.append("  ")
        
        lines.append(String(localized: "Line"))
        lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? ""))
        lines.append(String(localized: "Line"))
        
        if printViewModel.isOn(3) {
            let dt = printViewModel.frmatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.fullRow(dt) )
        }
        
        if printViewModel.isOn(4) {
            let d = printViewModel.dateFormatter.string(from: timeStamp)
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("DATE"), ":", d) )
        }
        
        if printViewModel.isOn(5) {
            let t = printViewModel.timeFormatter.string(from: timeStamp)
            lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":", t))
        }
        
//            lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", loadAxleItem.product ?? "N/A") )
//            lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", loadAxleItem.client ?? "N/A") )
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", serialNumber) )
        lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", vehicle) )
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
        ? printViewModel.inspectorNameText! + "     " : "------------"
        
        lines.append("  ")
        if printViewModel.inspectorNameText?.isEmpty == false {
            lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
        } else {
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
        }
        lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
        lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        return lines
    }
    
    // MARK: - Data Detail Sceen Balance Print Form

    static func buildPrintBalanceLinesData(
        loadAxleItem: LoadAxleInfo,
        dataViewModel: DataViewModel,
        printViewModel: PrintFormSettingViewModel,
        lang: LanguageManager
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
            
//            let item = loadAxleItem.product ?? "N/A"
//            let client = loadAxleItem.client ?? "N/A"
            let vehicle = loadAxleItem.vehicle ?? "N/A"
            let serialNumber = loadAxleItem.serialNumber ?? "N/A"
            
//            let productTitle = (dataViewModel.productTitle != nil)
//                ? lang.localized(dataViewModel.productTitle!)
//                : lang.localized("Item")
//            let clientTitle = (dataViewModel.clientTitle != nil)
//                ? lang.localized(dataViewModel.clientTitle!)
//                : lang.localized("Client")
            
            lines.append(String(localized: "Line"))
            lines.append(CommonPrintFormatter.fullRow(printViewModel.printHeadLineText ?? "Print Head Line"))
            lines.append(String(localized: "Line"))
            
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
                lines.append(CommonPrintFormatter.threeColRowLift(lang.localized("TIME"), ":", t))
            }
//            lines.append( CommonPrintFormatter.threeColRowLift(productTitle, ":", loadAxleItem.product ?? "N/A") )
//            lines.append( CommonPrintFormatter.threeColRowLift(clientTitle, ":", loadAxleItem.client ?? "N/A") )
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", serialNumber) )
            lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("Vehicle"), ":", vehicle) )
            lines.append(String(localized: "Line"))
            if left4 != 0 || right4 != 0 {
                lines.append( CommonPrintFormatter.threeColRowLift(lang.localized("S/N"), ":", serialNumber) )
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
        ? printViewModel.inspectorNameText! + "     " : "------------"
        
        lines.append("  ")
        if printViewModel.inspectorNameText?.isEmpty == false {
            lines.append( CommonPrintFormatter.threeColumnLine(lang.localized("Inspector"), ":", inspector) )
        } else {
            lines.append("  ")
            lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Inspector"), ":") )
            lines.append( CommonPrintFormatter.oneColRowEndDriver(inspector) )
        }
        lines.append( CommonPrintFormatter.twoColRowLeftInspector(lang.localized("Driver"), ":") )
        lines.append( CommonPrintFormatter.oneColRowEndDriver("------------") )
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
        lines.append("  ")
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
}

