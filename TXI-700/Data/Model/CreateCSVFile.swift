//
//  CreateCSVFile.swift
//  TXI-700
//
//  Created by 서용준 on 12/9/25.
//
import Foundation

enum CSVDataType {
    case selected(Int)
    case today
    case all
    case filtered
}

func createCSVFile(items: [LoadAxleInfo], type: CSVDataType) -> URL? {
    let filteredItems: [LoadAxleInfo]
    let calendar = Calendar.current
    
    switch type {
    case .today:
        filteredItems = items.filter { item in
            if let date = item.timestamp {
                return calendar.isDateInToday(date)
            }
            return false
        }
    case .all:
        filteredItems = items
    case .selected(let index):
        if index >= 0 && index < items.count {
            filteredItems = [items[index]]  // 선택된 하나의 index
        } else {
            print("Invalid index")
            return nil
        }
    case .filtered:
        filteredItems = items
    }
    
    let now = Date()
    
    let formatterNow = DateFormatter()
    formatterNow.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let dateString = formatterNow.string(from: now)
    
    let fileName = "LoadAxleData_\(dateString).csv"
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    var csvText = "Date, Vehicle, Client, Product, WeightNum, LoadAxle Left 1, LoadAxle Right 1, LoadAxle Left 2, LoadAxle Right 2\n"
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    for item in filteredItems {
        let arrayString: String
        if let data = item.loadAxleData {
            do {
                // JSON Data를 [Int]로 디코딩
                let loadAxles = try JSONDecoder().decode([Int].self, from: data)
                // 문자열로 변환
                arrayString = loadAxles.map { String($0)+"kg" }.joined(separator: ",")
            } catch {
                print("JSON 디코딩 실패: \(error)")
                arrayString = ""
            }
        } else {
            arrayString = ""
        }
        let timestampString = item.timestamp.map { formatter.string(from: $0) } ?? ""
        let weightNum = switch item.weightNum {
        case "0":
            "Indicator"
        case "1":
            "One-Step"
        case "2":
            "Two-Step"
        default:
            "Unknown"
        }
        let line =
        "\(timestampString)," +
        "\(item.vehicle ?? "N/A")," +
        "\(item.client ?? "N/A")," +
        "\(item.product ?? "N/A")," +
        "\(weightNum)," +
        "\(arrayString)\n"
        
        csvText.append(line)
    }
    
    do {
        try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
        let bom = "\u{FEFF}" // UTF-8 BOM
        let csvWithBOM = bom + csvText
        
        try csvWithBOM.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("CSV 파일 저장 실패: \(error.localizedDescription)")
        return nil
    }
}

func deleteAllCSVFilesInTempDirectory() {
    let tempDir = FileManager.default.temporaryDirectory
    
    do {
        let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension.lowercased() == "csv" {
            try FileManager.default.removeItem(at: file)
        }
    } catch {
        print("CSV 파일 삭제 실패:", error.localizedDescription)
    }
}
