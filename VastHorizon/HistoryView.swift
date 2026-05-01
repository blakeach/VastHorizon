// History view UI

import SwiftUI

struct HistoryView: View {
    // Stores transaction values in an array
    let transactions: [Transaction]
    
    // Allows user to close out of the screen
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()
            
            // Placeholder if there are no transactions
                if transactions.isEmpty {
                    VStack(spacing: 8) {
                        Text("No Transactions")
                            .font(.headline)
                        Text("Your history will appear here.")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
            // If there are transactions
                } else {
                    List(transactions.reversed()) {
                    transaction in TransactionRow(transaction: transaction)
                            .listRowBackground(Color.white.opacity(0.05))
                    }
                    .scrollContentBackground(.hidden)
                }
            }

        // History UI
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
}
