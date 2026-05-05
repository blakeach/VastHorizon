// MVVM ViewModel — owns all state, business logic, and RPG progression.

import SwiftUI

@Observable
class AccountViewModel {

    // MARK: - Persisted state keys
    private let balanceKey     = "vh_balance"
    private let isSetKey       = "vh_balance_set"
    private let transactionsKey = "vh_transactions"
    private let profileKey     = "vh_profile"

    // MARK: - Banking state
    var balance:       Double = 0.0
    var maxBalance:     Double = 0.0
    var isBalanceSet:  Bool   = false
    var transactions:  [Transaction] = []
    var selectedAction: BankAction? = nil

    // MARK: - RPG state
    var profile: PlayerProfile = PlayerProfile()

    // MARK: - UI state
    var alertMessage:    String = ""
    var showingAlert:    Bool   = false
    var showingHistory:  Bool   = false
    var showingBadges:   Bool   = false
    var showingLevelUp:  Bool   = false
    var levelUpMessage:  String = ""
    var newBadge:        Badge? = nil
    var showingNewBadge: Bool   = false

    var savedMonthlyFee: Double = UserDefaults.standard.object(forKey: "savedMonthlyFee") as? Double ?? 12.99 {
        didSet {
            UserDefaults.standard.set(savedMonthlyFee, forKey: "savedMonthlyFee")
        }
    }

    // MARK: - Init

    init() {
        loadAll()
        refreshStreak()
    }

    // MARK: - Computed

    var recentTransactions: [Transaction] {
        Array(transactions.suffix(3).reversed())
    }

    var totalDeposited: Double {
        transactions.filter { $0.type == .deposit }.reduce(0) { $0 + $1.amount }
    }

    var totalWithdrawn: Double {
        transactions.filter { $0.type != .deposit }.reduce(0) { $0 + $1.amount }
    }

    var streakIsActive: Bool { profile.currentStreak > 0 }

    // MARK: - Banking actions
    func setInitialBalance(_ input: String) {
        guard let val = Double(input), val >= 0 else { return }
        deposit(val)
        isBalanceSet = true
        saveAll()
    }

    func processTransaction(amountInput: String) {
        guard let amt = Double(amountInput), amt > 0 else { return }

        if selectedAction == .add {
            deposit(amt)
        } else {
            withdraw(amt)
        }
        selectedAction = nil
    }

    func applyFee(_ input: String) {
        let fee: Double
        if let newFee = Double(input), newFee > 0 {
            savedMonthlyFee = newFee
            fee = newFee
        } else {
            fee = savedMonthlyFee
        }

        guard balance >= fee else {
            alert("Not enough to cover the fee.")
            return
        }

        balance -= fee
        let txn = Transaction(type: .fee, amount: fee)
        transactions.append(txn)
        alert("Fee of \(fee.currency) applied.")
        saveAll()
    }

    // MARK: - Private banking

    private func deposit(_ amt: Double) {
        balance += amt
        profile.totalDeposited += amt
        
        
        if maxBalance < balance {
            let xpEarned = Int(balance - maxBalance)
            maxBalance = balance
            addXP(xpEarned)   // 1 XP per dollar
            let txn = Transaction(type: .deposit, amount: amt, xpEarned: xpEarned)
            transactions.append(txn)
            alert("Deposited \(amt.currency)  +\(xpEarned) XP")
        }
        else {
            let txn = Transaction(type: .deposit, amount: amt, xpEarned: 0)
            transactions.append(txn)
            alert("Deposited \(amt.currency)  +\(0) XP")
        }
        checkBadges()
        updateActivityDate()
        
        saveAll()
    }

    private func withdraw(_ amt: Double) {
        guard amt <= balance else {
            alert("Insufficient funds!")
            return
        }
        balance -= amt
        let txn = Transaction(type: .withdrawal, amount: amt)
        transactions.append(txn)

        // Reset streak on any withdrawal.
        profile.currentStreak = 0
        updateActivityDate()
        alert("Withdrew \(amt.currency)")
        saveAll()
    }

    // MARK: - RPG engine

    /// Adds XP and handles level-up if the threshold is crossed.
    func addXP(_ amount: Int) {
        let oldLevel = profile.level
        profile.xp += amount

        // Each level requires level * 100 cumulative XP.
        while profile.xp >= profile.level * 100 {
            profile.level += 1
            profile.xp = 0
            triggerLevelUp(to: profile.level)
        }

        // Badge checks on level milestones.
        if profile.level >= 5  && oldLevel < 5  { awardBadge(.level5) }
        if profile.level >= 10 && oldLevel < 10 { awardBadge(.level10) }
    }

    private func triggerLevelUp(to level: Int) {
        levelUpMessage = "Level \(level) reached!"
        showingLevelUp = true
    }

    /// Re-evaluates all badge conditions and awards any newly earned badges.
    func checkBadges() {
        // First deposit
        if transactions.filter({ $0.type == .deposit }).count == 1 {
            awardBadge(.firstDeposit)
        }
        // Emergency fund: balance >= $1,000
        if balance >= 1_000 {
            awardBadge(.emergencyFund)
        }
        // Centurion: $1,000 deposited in total
        if profile.totalDeposited >= 1_000 {
            awardBadge(.centurion)
        }
        // Streak badges (evaluated in refreshStreak)
    }

    func awardBadge(_ badge: Badge) {
        guard !profile.earnedBadgeIDs.contains(badge.rawValue) else { return }
        profile.awardBadge(badge)
        newBadge        = badge
        showingNewBadge = true
        saveAll()
    }

    // MARK: - Streak

    /// Called on init and whenever the app becomes active.
    func refreshStreak() {
        guard let last = profile.lastActivityDate else { return }
        let days = Date().daysDifference(from: last)

        if days == 1 {
            // One full day passed with no withdrawal — increment.
            profile.currentStreak += 1
            profile.longestStreak  = max(profile.longestStreak, profile.currentStreak)
        } else if days > 1 {
            // More than one day gap — streak broken.
            profile.currentStreak = 0
        }
        // days == 0: same day, no change.

        // Badge checks.
        if profile.currentStreak >= 7  { awardBadge(.weekStreak) }
        if profile.currentStreak >= 30 { awardBadge(.ironWill) }

        saveAll()
    }

    private func updateActivityDate() {
        profile.lastActivityDate = Date()
    }

    // MARK: - Persistence (UserDefaults / JSON)

    func saveAll() {
        UserDefaults.standard.set(balance,      forKey: balanceKey)
        UserDefaults.standard.set(isBalanceSet, forKey: isSetKey)

        if let txnData = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(txnData, forKey: transactionsKey)
        }
        if let profData = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(profData, forKey: profileKey)
        }
    }

    private func loadAll() {
        balance      = UserDefaults.standard.double(forKey: balanceKey)
        isBalanceSet = UserDefaults.standard.bool(forKey: isSetKey)

        if let txnData = UserDefaults.standard.data(forKey: transactionsKey),
           let txns = try? JSONDecoder().decode([Transaction].self, from: txnData) {
            transactions = txns
        }
        if let profData = UserDefaults.standard.data(forKey: profileKey),
           let prof = try? JSONDecoder().decode(PlayerProfile.self, from: profData) {
            profile = prof
        }
    }

    // MARK: - Helpers

    private func alert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
