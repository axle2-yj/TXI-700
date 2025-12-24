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
    
    var id: String {
        switch self {
            case .error(let message):
            return message
        }
    }
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

@MainActor
class ProductViewModel: ObservableObject {
    @Published var productItems: [ProductInfo] = []
    @Published var text: String = NSLocalizedString("ProductScreenTitle", comment: "")
    @Published var name: String = ""
    @Published var num: Int16 = 0
    @Published var selectedProduct: ProductInfo? = nil

    private let productManager = ProductDataManager.shared
    
    func fetchProductItems() {
        productItems = productManager.fetchAll()
    }
    
    func saveOrUpdateProcduct() {
        guard !name.isEmpty else {
            print("상품 이름은 필수입니다.")
            return
        }
        if let product = selectedProduct {
                // UPDATE
                productManager.updateProduct(
                    item: product,
                    name: name.replacingOccurrences(of: " ", with: ""),
                    num: product.num
                )
            } else {
                // ADD
                let nextNum = Int16(productItems.count)
                productManager.addProduct(name: name.replacingOccurrences(of: " ", with: ""), num: nextNum)
            }

            fetchProductItems()
            clearSelection()
    }
    
    func updateProduct(item: ProductInfo, name: String, num: Int16) {
        productManager.updateProduct(item: item, name: name, num: num)
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
