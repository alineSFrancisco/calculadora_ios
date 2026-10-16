//
//  Calculadora.swift
//  Calculadora
//
//  Created by Aline Silva on 16/10/26.
//

import Foundation
import SwiftUI

@Observable
final class Calculadora {

    private(set) var entrada: String = "0"
    private(set) var valorGuardado: Double = 0
    private(set) var operacaoPendente: String?
    private(set) var iniciarNovaEntrada = true

    var ocorreuErro: Bool {
        entrada == "Erro"
    }

    func digitar(_ digito: String) {
        if ocorreuErro {
            limpar()
        }

        if iniciarNovaEntrada || entrada == "0" {
            entrada = digito
            iniciarNovaEntrada = false
        } else if entrada.count < 14 {
            entrada += digito
        }
    }

    func digitarPonto() {
        if ocorreuErro {
            limpar()
        }

        if iniciarNovaEntrada {
            entrada = "0."
            iniciarNovaEntrada = false
        } else if !entrada.contains(".") {
            entrada += "."
        }
    }

    func escolherOperacao(_ operacao: String) {
        guard !ocorreuErro else { return }

        let atual = Double(entrada) ?? 0

        if let pendente = operacaoPendente,
           !iniciarNovaEntrada {

            guard let resultado = calcular(
                valorGuardado,
                atual,
                operacao: pendente
            ) else {
                mostrarErro()
                return
            }

            valorGuardado = resultado
            entrada = formatar(resultado)
        } else {
            valorGuardado = atual
        }

        operacaoPendente = operacao
        iniciarNovaEntrada = true
    }

    func calcularResultado() -> String? {
        guard
            !ocorreuErro,
            let operacao = operacaoPendente,
            !iniciarNovaEntrada
        else {
            return nil
        }

        let segundoValor = Double(entrada) ?? 0

        guard let resultado = calcular(
            valorGuardado,
            segundoValor,
            operacao: operacao
        ) else {
            mostrarErro()
            return nil
        }

        entrada = formatar(resultado)
        valorGuardado = resultado
        operacaoPendente = nil
        iniciarNovaEntrada = true

        return entrada
    }

    func limpar() {
        entrada = "0"
        valorGuardado = 0
        operacaoPendente = nil
        iniciarNovaEntrada = true
    }

    func apagar() {
        if ocorreuErro {
            limpar()
            return
        }

        if iniciarNovaEntrada && operacaoPendente != nil {
            return
        }

        iniciarNovaEntrada = false

        if entrada.count > 1 {
            entrada.removeLast()
        } else {
            entrada = "0"
        }

        if entrada == "-" || entrada.isEmpty {
            entrada = "0"
        }
    }

    func inverterSinal() {
        guard !ocorreuErro, entrada != "0" else { return }

        if entrada.hasPrefix("-") {
            entrada.removeFirst()
        } else {
            entrada = "-" + entrada
        }
    }

    func porcentagem() {
        guard !ocorreuErro else { return }

        entrada = formatar((Double(entrada) ?? 0) / 100)
        iniciarNovaEntrada = true
    }

    private func calcular(
        _ primeiro: Double,
        _ segundo: Double,
        operacao: String
    ) -> Double? {
        let resultado: Double

        switch operacao {
        case "+": resultado = primeiro + segundo
        case "−": resultado = primeiro - segundo
        case "×": resultado = primeiro * segundo
        case "÷":
            guard segundo != 0 else { return nil }
            resultado = primeiro / segundo
        default:
            return nil
        }

        return resultado.isFinite ? resultado : nil
    }

    private func mostrarErro() {
        entrada = "Erro"
        valorGuardado = 0
        operacaoPendente = nil
        iniciarNovaEntrada = true
    }

    private func formatar(_ valor: Double) -> String {
        if valor == valor.rounded(.towardZero),
           abs(valor) < 1e15 {
            return String(format: "%.0f", locale: Locale(identifier: "en_US_POSIX"), valor)
        }

        var resultado = String(
            format: "%.8f",
            locale: Locale(identifier: "en_US_POSIX"),
            valor
        )

        while resultado.contains(".") && resultado.last == "0" {
            resultado.removeLast()
        }

        if resultado.last == "." {
            resultado.removeLast()
        }

        return resultado == "-0" ? "0" : resultado
    }
}
