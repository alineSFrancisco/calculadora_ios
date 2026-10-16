//
//  ContentView.swift
//  Calculadora
//
//  Created by Aline Silva on 16/10/26.
//


import SwiftUI

struct ContentView: View {

    @State private var calculadora = Calculadora()
    @State private var historico = HistoricoCalculadora()
    @State private var expressao = ""

    private let roxo = Color(red: 0.65, green: 0.36, blue: 1.0)
    private let azul = Color(red: 0.26, green: 0.68, blue: 1.0)
    private let texto = Color(red: 0.96, green: 0.95, blue: 1.0)
    private let textoSuave = Color(red: 0.63, green: 0.64, blue: 0.77)

    private let teclas = [
        "AC", "⌫", "%", "÷",
        "7", "8", "9", "×",
        "4", "5", "6", "−",
        "1", "2", "3", "+",
        "±", "0", ".", "="
    ]

    private let colunas = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 4
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.047, green: 0.055, blue: 0.133),
                    Color(red: 0.086, green: 0.067, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    cabecalho
                    painelCalculadora
                    painelHistorico
                }
                .padding(20)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var cabecalho: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("CALCULADORA")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(2)

                Text("NEON EDITION")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(3)
                    .foregroundStyle(textoSuave)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 25))
                .foregroundStyle(
                    LinearGradient(
                        colors: [roxo, azul],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .foregroundStyle(texto)
    }

    private var painelCalculadora: some View {
        VStack(spacing: 22) {
            VStack(alignment: .trailing, spacing: 10) {
                Text(expressao.isEmpty ? " " : expressao)
                    .font(.system(size: 17))
                    .foregroundStyle(textoSuave)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(calculadora.entrada)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(texto)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            LazyVGrid(columns: colunas, spacing: 10) {
                ForEach(teclas, id: \.self) { tecla in
                    Button {
                        executar(tecla)
                    } label: {
                        Text(tecla)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(texto)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(corDaTecla(tecla))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.25))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                }
        )
    }

    private var painelHistorico: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("HISTÓRICO")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2)

                Spacer()

                Button("Limpar") {
                    historico.limpar()
                }
                .font(.system(size: 12))
                .foregroundStyle(textoSuave)
            }

            if historico.contas.isEmpty {
                Text("Suas contas recentes aparecerão aqui")
                    .font(.system(size: 13))
                    .foregroundStyle(textoSuave)
            } else {
                ForEach(
                    Array(historico.contas.enumerated()),
                    id: \.offset
                ) { _, conta in
                    Text(conta)
                        .font(.system(size: 14))
                        .foregroundStyle(texto)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            .white.opacity(0.05),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.035))
        )
    }

    private func corDaTecla(_ tecla: String) -> LinearGradient {
        let cores: [Color]

        switch tecla {
        case "=":
            cores = [roxo, azul]
        case "+", "−", "×", "÷":
            cores = [
                Color(red: 0.53, green: 0.29, blue: 0.91),
                roxo
            ]
        case "AC", "⌫", "%", "±":
            cores = [
                Color(red: 0.20, green: 0.20, blue: 0.31),
                Color(red: 0.20, green: 0.20, blue: 0.31)
            ]
        default:
            cores = [
                Color(red: 0.19, green: 0.19, blue: 0.31),
                Color(red: 0.19, green: 0.19, blue: 0.31)
            ]
        }

        return LinearGradient(
            colors: cores,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func executar(_ tecla: String) {
        switch tecla {
        case "AC":
            calculadora.limpar()
            expressao = ""

        case "⌫":
            calculadora.apagar()
            atualizarExpressao()

        case "%":
            calculadora.porcentagem()
            atualizarExpressao()

        case "±":
            calculadora.inverterSinal()
            atualizarExpressao()

        case ".":
            calculadora.digitarPonto()
            atualizarExpressao()

        case "=":
            finalizarCalculo()

        case "+", "−", "×", "÷":
            calculadora.escolherOperacao(tecla)
            expressao = "\(calculadora.valorGuardado) \(tecla)"

        default:
            calculadora.digitar(tecla)
            atualizarExpressao()
        }
    }

    private func atualizarExpressao() {
        if calculadora.ocorreuErro {
            expressao = ""
        } else if let operacao = calculadora.operacaoPendente {
            expressao = "\(calculadora.valorGuardado) \(operacao)"
        } else {
            expressao = ""
        }
    }

    private func finalizarCalculo() {
        let operacao = calculadora.operacaoPendente
        let primeiro = calculadora.valorGuardado
        let segundo = Double(calculadora.entrada) ?? 0

        guard let operacao else { return }

        let conta = "\(primeiro) \(operacao) \(segundo)"

        if let resultado = calculadora.calcularResultado() {
            expressao = "\(conta) ="
            historico.adicionar("\(expressao) \(resultado)")
        } else if calculadora.ocorreuErro {
            expressao = ""
        }
    }
}

#Preview {
    ContentView()
}
