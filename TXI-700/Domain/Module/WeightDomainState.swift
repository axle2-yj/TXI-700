

//
//  WeightDomainSate.swift
//  TXI-700
//
//  Created by 서용준 on 1/5/26.
//

struct WeightDomainState {
    var axles: [Int: AxleState]
    var mode: WeightMode
    var isStable: Bool
}
