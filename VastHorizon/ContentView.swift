// ContentView.swift
// Main dashboard — pure UI layer, delegates all logic to AccountViewModel.

import SwiftUI

struct ContentView: View {

    // MARK: - ViewModel

    @State private var vm = AccountViewModel()

    // MARK: - Local UI state (ephemeral text field strings only)

    @State private var balanceInput    = ""
    @State private var amountInput     = ""
    @State private var customFeeInput  = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "04203E").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        xpSection
                        balanceCard
                        if vm.selectedAction != nil { transactionInputArea }
                        actionGrid
                        if !vm.transactions.isEmpty { recentActivitySection }
                    }
                    .padding(.bottom, 30)
                }

                // Overlays (level-up, badge unlock) sit above everything.
                if vm.showingLevelUp {
                    LevelUpOverlay(message: vm.levelUpMessage) {
                        withAnimation { vm.showingLevelUp = false }
                    }
                    .zIndex(10)
                }

                if vm.showingNewBadge, let badge = vm.newBadge {
                    NewBadgeOverlay(badge: badge) {
                        withAnimation { vm.showingNewBadge = false }
                    }
                    .zIndex(9)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture { hideKeyboard() }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $vm.showingHistory) {
            HistoryView(transactions: vm.transactions)
        }
        .sheet(isPresented: $vm.showingBadges) {
            BadgesView(profile: vm.profile)
        }
        .alert("Bank Update", isPresented: $vm.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.alertMessage)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("VASTHORIZON BANK")
                    .font(.caption.bold().monospaced())
                    .tracking(4)
                    .foregroundColor(.red)
                Text("Personal Account")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            Spacer()
            StreakChip(streak: vm.profile.currentStreak)
        }
        .padding(.horizontal)
        .padding(.top, 21)
    }

    // MARK: - XP Bar

    private var xpSection: some View {
        VStack(spacing: 12) {
            XPBar(profile: vm.profile)

            // Badges shortcut row — shows first 4 earned badges as small icons.
            if !vm.profile.earnedBadges.isEmpty {
                HStack(spacing: 8) {
                    Text("BADGES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(2)

                    ForEach(vm.profile.earnedBadges.prefix(4)) { badge in
                        Image(systemName: badge.icon)
                            .font(.system(size: 14))
                            .foregroundColor(badge.color)
                    }

                    if vm.profile.earnedBadges.count > 4 {
                        Text("+\(vm.profile.earnedBadges.count - 4)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button("View all") { vm.showingBadges = true }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "F39C12"))
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04)))
        .padding(.horizontal)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 12) {
            Text("AVAILABLE BALANCE")
                .font(.caption2.bold())
                .foregroundColor(.gray)

            ZStack {
                BalanceMeter(balance: vm.balance)
                Text(vm.balance.currency)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }

            if !vm.isBalanceSet {
                HStack {
                    TextField("0.00", text: $balanceInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)

                    Button("Set") {
                        vm.setInitialBalance(balanceInput)
                        balanceInput = ""
                        hideKeyboard()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
        }
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.05)))
        .padding(.horizontal)
    }

    // MARK: - Transaction Input

    private var transactionInputArea: some View {
        VStack(spacing: 15) {
            TextField("Amount", text: $amountInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))

            HStack {
                Button("Cancel") {
                    vm.selectedAction = nil
                    amountInput = ""
                }
                .foregroundColor(.gray)

                Spacer()

                Button("Confirm Transaction") {
                    vm.processTransaction(amountInput: amountInput)
                    amountInput = ""
                    hideKeyboard()
                }
                .fontWeight(.bold)
                .foregroundColor(vm.selectedAction == .add ? .green : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Action Grid

    private var actionGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ActionButton(title: "Deposit", color: .green, isSelected: vm.selectedAction == .add) {
                    withAnimation { vm.selectedAction = .add }
                }
                ActionButton(title: "Withdraw", color: .red, isSelected: vm.selectedAction == .withdraw) {
                    withAnimation { vm.selectedAction = .withdraw }
                }
            }

            HStack(spacing: 12) {
                TextField(vm.savedMonthlyFee.currency, text: $customFeeInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)

                ActionButton(title: "Pay Fee", color: .orange, isSelected: false) {
                    vm.applyFee(customFeeInput)
                    customFeeInput = ""
                    hideKeyboard()
                }
            }

            HStack(spacing: 12) {
                ActionButton(title: "History", color: .purple, isSelected: false) {
                    vm.showingHistory = true
                }
                ActionButton(title: "Badges", color: Color(hex: "F39C12"), isSelected: false) {
                    vm.showingBadges = true
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("RECENT ACTIVITY")
                .font(.caption.bold())
                .foregroundColor(.gray)

            ForEach(vm.recentTransactions) { transaction in
                TransactionRow(transaction: transaction)
            }

            if vm.transactions.count > 3 {
                Button("View all \(vm.transactions.count) transactions →") {
                    vm.showingHistory = true
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
