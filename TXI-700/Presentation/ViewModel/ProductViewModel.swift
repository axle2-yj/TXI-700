//
//  ProductViewModel.swift
//  TXI-700
//
//  Created by 서용준 on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
class ProductViewModel: ObservableObject {
    @Published var productItems: [ProductInfo] = []
    @Published var text: String = NSLocalizedString("ProductScreenTitle", comment: "")
    @Published var name: String = ""
    
    private let productManger = ProductDataManager.shared
    
    func fetchProductItems() {
        productItems = productManger.fetchAll()
    }
    
    func addProdut() {
        productManger.addProduct(name: name)
        fetchProductItems()
        name = ""
    }
    
    func deleteProduct(item: ProductInfo) {
        productManger.delete(item: item)
        fetchProductItems()
    }
}
