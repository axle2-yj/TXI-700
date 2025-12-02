//
//  UINavigationController.swift
//  TXI-700
//
//  Created by 서용준 on 12/3/25.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}
