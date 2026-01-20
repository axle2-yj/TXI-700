//
//  DeleteButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI
import Foundation

struct DeleteButton: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: DataViewModel
    
    @Binding var loadAxleItem: LoadAxleInfo
    @Binding var currentIndex: Int
    
    private var tint: Color {
        colorScheme == .dark ? .white : .black
    }
    private var oppositionTint: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var onRequestDelete: () -> Void
    
    var body: some View {
        Button {
            if viewModel.selectedType != nil {
                onRequestDelete()
            }
        } label: {
            Text("DELETE")
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
                    ? oppositionTint
                    : tint
                )
                .disabled(viewModel.selectedType == nil)
                .contentShape(Rectangle())
        }
    }
}
