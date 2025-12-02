//
//  DeleteButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI
import Foundation

struct DeleteButton: View {
    @ObservedObject var viewModel: DataViewModel
    
    @Binding var loadAxleItem: LoadAxleInfo
    @Binding var currentIndex: Int

    var onRequestDelete: () -> Void
    
        var body: some View {
            Button("DELETE") {
                        onRequestDelete()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.selectedType == nil
                        ? Color.gray.opacity(0.4)
                        : Color.gray.opacity(0.2)
                    )
                    .cornerRadius(6)
                    .foregroundColor(
                        viewModel.selectedType == nil
                        ? .white
                        : .black
                    )
                    .disabled(viewModel.selectedType == nil)
        }
}
