// Creates unique event, and categorizes buttons with labels and colors

import SwiftUI

// Code safety for typos
enum BankAction {
    case add, withdraw
}
enum TransactionType {
    case deposit, withdrawal, fee

// Text labels
    var label: String {
        switch self {
        case .deposit: return "Deposit"
        case .withdrawal: return "Withdrawal"
        case .fee: return "Monthly Fee"
        }
    }

// Colors
    var color: Color {
        switch self {
        case .deposit: return Color(hex: "27AE60")
        case .withdrawal: return Color(hex: "E74C3C")
        case .fee: return Color(hex: "F39C12")
        }
    }
}

// Tracks each event for the history
struct Transaction: Identifiable {
// Generates unique id (ex: 2 $20, each has own ID)
    let id = UUID()

    let type: TransactionType // Withdrawal,Deposit,Fee
    let amount: Double
    let date = Date() // Captures exact date action was made

// Date and time
    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}
