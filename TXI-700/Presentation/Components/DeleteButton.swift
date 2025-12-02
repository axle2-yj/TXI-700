//
//  DeleteButton.swift
//  TXI-700
//
//  Created by 서용준 on 12/5/25.
//

import SwiftUI
import Foundation

struct DeleteButton: View {
    @State var checeked: Int?
    @State var loadAxleItem: LoadAxleInfo

    @ObservedObject var viewModel: DataViewModel
    
    var body: some View {
        Button("Delete") {
            switch checeked {
            case 0:
                viewModel.selectedDeleteLoadAxle(item: loadAxleItem)
                print("selected Data Delete")
            case 1:
                viewModel.todayDeleteLoadAxle()
                print("today Data Delete")
            case 2:
                viewModel.allDeleteLoadAxle(item: loadAxleItem)
                print("all Data Delete")
            default:
                break
            }
        }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
            .foregroundColor(.black)
    }
}
