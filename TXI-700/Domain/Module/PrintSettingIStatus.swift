//
//  PrintSettingIStatus.swift
//  TXI-700
//
//  Created by 서용준 on 12/4/25.
//

import Foundation

struct PrintSettingIStatus: Identifiable {
    var id =  UUID()
    var title : String
    var isOn: Bool
    var action: (Bool) -> Void
}
