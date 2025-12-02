//
//  Extension.swift
//  TXI-700
//
//  Created by 서용준 on 12/11/25.
//
import SwiftUI

extension String {
    func localized(_ language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
    }
}
