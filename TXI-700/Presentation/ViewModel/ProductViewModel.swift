//
//  ProductViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

enum ActiveListAlert: Identifiable {
    case error(String)
    case success(String)
    
    var id: String {
        switch self {
        case .error(let message):
            return message
        case .success(let message):
            return message
        }
    }
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        case .success(let message):
            return message
        }
    }
}

@MainActor
class ProductViewModel: ObservableObject {
    @Published var productItems: [ProductInfo] = []
    @Published var text: String = NSLocalizedString("ProductScreenTitle", comment: "")
    @Published var name: String = ""
    @Published var selectedProduct: ProductInfo? = nil
    @Published var saveSuccessMessage: String? = nil
    @Published var saveFailedMessage: String? = nil
    
    @EnvironmentObject var languageManager: LanguageManager
    
    private let productManager = ProductDataManager.shared
    
    func fetchProductItems() {
        productItems = productManager.fetchAll()
    }
    
    func saveOrUpdateProcduct() {
        guard !name.isEmpty else {
            saveFailedMessage = "pleaseEnterProductName"
            return
        }
        
        // 중복 체크
        if productItems.contains(where: { $0.name == name && $0.id != selectedProduct?.id}) {
            saveFailedMessage = "registeredProductName"
            return
        }
        
        if let product = selectedProduct {
            // UPDATE
            productManager.updateProduct(
                item: product,
                name: name.replacingOccurrences(of: " ", with: ""),
                num: product.num,
                shortcutNum: product.shortcutNum
            )
        } else {
            // ADD
            let nextNum = Int16(productItems.count)
            let netxShortcutNum = Int16(productItems.count)
            productManager.addProduct(name: name.replacingOccurrences(of: " ", with: ""), num: nextNum, shortcutNum: netxShortcutNum)
        }
        
        fetchProductItems()
        clearSelection()
        saveSuccessMessage = "saved"
    }
    
    func updateProduct(item: ProductInfo, name: String, num: Int16, shortcutNum: Int16) {
        productManager.updateProduct(item: item, name: name, num: num, shortcutNum: shortcutNum)
        fetchProductItems()
    }
    
    func deleteProduct(item: ProductInfo) {
        productManager.delete(item: item)
        fetchProductItems()
    }
    
    // MARK: - Reorder (롱클릭 이동)
    func moveProduct(from source: IndexSet, to destination: Int) {
        productItems.move(fromOffsets: source, toOffset: destination)
        reorderNum()
    }
    // MARK: - num 재정렬 공통 처리
    private func reorderNum() {
        for index in productItems.indices {
            productItems[index].num = Int16(index)
        }
        productManager.save()
    }
    
    func selectProduct(_ product: ProductInfo) {
        selectedProduct = product
        name = product.name ?? ""
    }
    
    func clearSelection() {
        selectedProduct = nil
        name = ""
    }
}
