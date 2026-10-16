//
//  HistoricoCalculadora.swift
//  Calculadora
//
//  Created by Aline Silva on 16/10/26.
//

import Foundation
import SwiftUI

@Observable
final class HistoricoCalculadora {

    private(set) var contas: [String] = []

    func adicionar(_ conta: String) {
        contas.insert(conta, at: 0)
    }

    func limpar() {
        contas.removeAll()
    }
}
