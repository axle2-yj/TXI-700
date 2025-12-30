//
//  MainWeightText.swift
//  TXI-700
//
//  Created by 서용준 on 12/23/25.
//

import SwiftUI

struct TableColumn<Content: View>: View {
    let alignment: Alignment
    let content: Content
    
    init(alignment: Alignment, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}

struct MainWeightText: View {
    let value: Int
    var body: some View {
        HStack {
            Text(String(value))
                .font(Font.custom("TI-1700FONT", size: 20))
            Text("kg")
                .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
