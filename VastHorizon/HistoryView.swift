// HistoryView.swift
// Modal sheet showing the full transaction ledger with totals.

import SwiftUI

struct HistoryView: View {

    let transactions: [Transaction]

    @Environment(\.dismiss) private var dismiss

    private var totalIn: Double {
        transactions.filter { $0.type == .deposit }.reduce(0) { $0 + $1.amount }
    }

    private var totalOut: Double {
        transactions.filter { $0.type != .deposit }.reduce(0) { $0 + $1.amount }
    }

    private var totalXP: Int {
        transactions.reduce(0) { $0 + $1.xpEarned }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                if transactions.isEmpty {
                    emptyState
                } else {
                    transactionList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text("No Transactions")
                .font(.headline)
            Text("Your history will appear here.")
                .font(.subheadline)
        }
        .foregroundColor(.gray)
    }

    private var transactionList: some View {
        List {
            summaryStrip
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            Section {
                ForEach(transactions.reversed()) { transaction in
                    TransactionRow(transaction: transaction)
                        .listRowBackground(Color.white.opacity(0.05))
                }
            } header: {
                Text("ALL TRANSACTIONS")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var summaryStrip: some View {
        HStack(spacing: 0) {
            summaryCell(label: "Total In",  value: totalIn.currency,    color: Color(hex: "27AE60"))
            Divider().frame(height: 36).background(Color.white.opacity(0.1))
            summaryCell(label: "Total Out", value: totalOut.currency,   color: Color(hex: "E74C3C"))
            Divider().frame(height: 36).background(Color.white.opacity(0.1))
            summaryCell(label: "XP Earned", value: "\(totalXP) XP",    color: Color(hex: "F39C12"))
        }
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }

    private func summaryCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
