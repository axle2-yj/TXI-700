//
//  CheckBoxAuto.swift
//  TXI-700
//
//  Created by 서용준 on 12/23/25.
//
import SwiftUI

struct CheckBoxAuto: View {
    @Binding var isChecked: Bool
    
    @ObservedObject var viewModel: HomeViewModel
    
    var label: String
    var body: some View {
        Button {
            isChecked.toggle()
            
            viewModel.setAutoConnectState(isChecked)
            
        } label: {
            HStack(spacing: 8) {
                Text(label)
                    .foregroundColor(.primary)
                
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(isChecked ? .blue : .gray)
            }
        }
    }
}
