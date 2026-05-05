// Models.swift
// Domain types: transactions, RPG progression, badges.

import SwiftUI

// MARK: - BankAction

enum BankAction {
    case add, withdraw
}

// MARK: - TransactionType

enum TransactionType: String, Codable {
    case deposit, withdrawal, fee

    var label: String {
        switch self {
        case .deposit:    return "Deposit"
        case .withdrawal: return "Withdrawal"
        case .fee:        return "Monthly Fee"
        }
    }

    var color: Color {
        switch self {
        case .deposit:    return Color(hex: "27AE60")
        case .withdrawal: return Color(hex: "E74C3C")
        case .fee:        return Color(hex: "F39C12")
        }
    }

    var symbolName: String {
        switch self {
        case .deposit:    return "arrow.down.circle.fill"
        case .withdrawal: return "arrow.up.circle.fill"
        case .fee:        return "calendar.circle.fill"
        }
    }
}

// MARK: - Transaction

struct Transaction: Identifiable, Codable {
    let id:     UUID
    let type:   TransactionType
    let amount: Double
    let date:   Date
    let xpEarned: Int

    init(type: TransactionType, amount: Double, xpEarned: Int = 0) {
        self.id       = UUID()
        self.type     = type
        self.amount   = amount
        self.date     = Date()
        self.xpEarned = xpEarned
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }

    var signedAmount: String {
        let prefix = (type == .deposit) ? "+" : "−"
        return "\(prefix)\(CurrencyFormatter.format(amount))"
    }
}

// MARK: - Badge

enum Badge: String, CaseIterable, Codable, Identifiable {
    case firstDeposit   = "first_deposit"
    case weekStreak     = "week_streak"
    case emergencyFund  = "emergency_fund"
    case level5         = "level_5"
    case level10        = "level_10"
    case centurion      = "centurion"       // $1,000 deposited total
    case ironWill       = "iron_will"       // 30-day streak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstDeposit:  return "First Deposit"
        case .weekStreak:    return "Iron Discipline"
        case .emergencyFund: return "Emergency Fund"
        case .level5:        return "Rising Saver"
        case .level10:       return "Wealth Builder"
        case .centurion:     return "Centurion"
        case .ironWill:      return "Iron Will"
        }
    }

    var description: String {
        switch self {
        case .firstDeposit:  return "Made your first deposit."
        case .weekStreak:    return "7 days without an impulse buy."
        case .emergencyFund: return "Reached a $1,000 safety net."
        case .level5:        return "Reached Level 5."
        case .level10:       return "Reached Level 10."
        case .centurion:     return "Deposited $1,000 in total."
        case .ironWill:      return "30 days without a withdrawal."
        }
    }

    var icon: String {
        switch self {
        case .firstDeposit:  return "star.fill"
        case .weekStreak:    return "flame.fill"
        case .emergencyFund: return "shield.fill"
        case .level5:        return "bolt.fill"
        case .level10:       return "crown.fill"
        case .centurion:     return "medal.fill"
        case .ironWill:      return "lock.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstDeposit:  return Color(hex: "F39C12")
        case .weekStreak:    return Color(hex: "E74C3C")
        case .emergencyFund: return Color(hex: "2980B9")
        case .level5:        return Color(hex: "8E44AD")
        case .level10:       return Color(hex: "D4AC0D")
        case .centurion:     return Color(hex: "D35400")
        case .ironWill:      return Color(hex: "1ABC9C")
        }
    }

    // Condition is evaluated inside the ViewModel.
    var xpReward: Int {
        switch self {
        case .firstDeposit:  return 10
        case .weekStreak:    return 50
        case .emergencyFund: return 100
        case .level5:        return 0   // granted on level-up, no bonus
        case .level10:       return 0
        case .centurion:     return 75
        case .ironWill:      return 150
        }
    }
}

// MARK: - PlayerProfile (Codable for persistence)

struct PlayerProfile: Codable {
    var xp:               Int     = 0
    var level:            Int     = 1
    var currentStreak:    Int     = 0
    var longestStreak:    Int     = 0
    var earnedBadgeIDs:   [String] = []
    var lastActivityDate: Date?   = nil
    var totalDeposited:   Double  = 0.0

    // XP required to reach the next level (linear: 100 XP per level).
    var xpForNextLevel: Int { level * 100 }

    // Progress 0.0 – 1.0 within current level.
    var levelProgress: Double {
        let base    = (level - 1) * 100
        let current = xp - base
        return min(Double(current) / Double(xpForNextLevel - base), 1.0)
    }

    var earnedBadges: [Badge] {
        earnedBadgeIDs.compactMap { Badge(rawValue: $0) }
    }

    mutating func awardBadge(_ badge: Badge) {
        guard !earnedBadgeIDs.contains(badge.rawValue) else { return }
        earnedBadgeIDs.append(badge.rawValue)
        xp += badge.xpReward
    }
}

// MARK: - CurrencyFormatter

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    static func format(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
