// Defines properties when button is active, transaction column UI and labels, and formats the currency

import SwiftUI

struct ActionButton: View {
    // Defines all the properties for the buttons
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
        // Execute action for button
            VStack(spacing: 8) {
        // Properties that change button's color, font, etc. for visibility that it has been selected
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
    }
}

// Transaction column when active
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                // Transaction type label (ex: Deposit or Withdraw)
                Text(transaction.type.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                // Date and time for fun
                Text(transaction.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
        // Shows dollar amount where it is +/-
            Text(transaction.type == .deposit ? "+\(format(transaction.amount))" : "-\(format(transaction.amount))")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(transaction.type == .deposit ? Color(hex: "27AE60") : Color(hex: "E74C3C"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    // Function to format currency amount
    func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
