//
//  CheckBox.swift
//  TXI-700
//
//  Created by 서용준 on 12/11/25.
//

import SwiftUI

struct CheckBox: View {
    @Binding var isChecked: Bool
    
    @ObservedObject var viewModel: SettingViewModel
    
    var label: String
    var select: String
    var body: some View {
        Button {
            isChecked.toggle()
            
            switch select {
            case "product":
                viewModel.saveProductCkeck(isChecked)
            case "client":
                viewModel.saveClientCkeck(isChecked)
            default :
                break
            }
        } label: {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(isChecked ? .blue : .gray)
                
                Text(label)
                    .foregroundColor(.primary)
            }
        }
    }
}
