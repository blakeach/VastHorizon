// The UI when the user opens the app

import SwiftUI

#Preview {
    ContentView()
}

struct ContentView: View {
    // Tracks input for balance, amount
    @State private var balance: Double = 0.0
    @State private var balanceInput: String = ""
    @State private var amountInput: String = ""
    
    // Tracks history
    @State private var purchaseHistory: [Transaction] = []
    @State private var selectedAction: BankAction? = nil

    // Setting the states of variables when opening the app
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingHistory = false
    @State private var isBalanceSet = false
    
    // Stores fee input (12.99 is the placeholder)
    @AppStorage("savedMonthlyFee") private var savedMonthlyFee: Double = 12.99
    @State private var customFeeInput: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Home background
                Color(hex: "04203E").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Dashboard components
                        headerSection
                        balanceCard
                        
                        // Only displays input field if action is chosen
                        if selectedAction != nil {
                            transactionInputArea
                        }
                      
                        // Buttons
                        actionGrid
                        
                        // Only displays history if there is data stored
                        if !purchaseHistory.isEmpty {
                            recentActivitySection
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
        // Sets app to dark mode
        .preferredColorScheme(.dark)
        
        // UI sheet for transaction history
        .sheet(isPresented: $showingHistory) {
            HistoryView(transactions: purchaseHistory)
        }
     
        // Alert handler for confirming all actions or returning errors
        .alert("Bank Update", isPresented: $showingAlert) {
            Button("Ok!", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Headers for "VastHorizon Bank" and "Personal Account"
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("VASTHORIZON BANK").font(.caption.bold().monospaced()).tracking(4).foregroundColor(.red)
            Text("Personal Account").font(.title2.bold()).foregroundColor(.white)
        }
        .padding(.top, 21)
    }

    // The field for setting up user's balance
    private var balanceCard: some View {
        VStack(spacing: 12) {
            // Label
            Text("AVAILABLE BALANCE").font(.caption2.bold()).foregroundColor(.gray)
          
            // Balance Display
            Text(formatCurrency(balance))
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
    
            // Logic if balance is not set
            if !isBalanceSet {
                HStack {
                    TextField("0.00", text: $balanceInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button("Set") {
                        setInitialBalance()
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

    // Field for Depositing or Withdrawing
    private var transactionInputArea: some View {
        VStack(spacing: 15) {
            TextField("Amount", text: $amountInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
            
            HStack {
                Button("Cancel") { selectedAction = nil; amountInput = "" }
                    .foregroundColor(.gray)
                Spacer()
                Button("Confirm Transaction") { processTransaction() }
                    .fontWeight(.bold)
                    .foregroundColor(selectedAction == .add ? .green : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
        .padding(.horizontal)
    }
    
    // Grid of buttons for main actions
    private var actionGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Deposit Button
                ActionButton(title: "Deposit", color: .green, isSelected: selectedAction == .add) {
                    selectedAction = .add
                }
                // Withdraw Button
                ActionButton(title: "Withdraw", color: .red, isSelected: selectedAction == .withdraw) {
                    selectedAction = .withdraw
                }
            }
            
            HStack(spacing: 12) {
                // Input field for monthly fee
                TextField("\(formatCurrency(savedMonthlyFee))", text: $customFeeInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                
                // Pay Fee button
                ActionButton(title: "Pay Fee", color: .orange, isSelected: false) {
                    applyFee()
                }
            }

            // History button
            ActionButton(title: "History", color: .purple, isSelected: false) {
                showingHistory = true
            }
        }
        .padding(.horizontal)
    }

    // The list of recent activity of actions
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("RECENT ACTIVITY")
                .font(.caption.bold())
                .foregroundColor(.gray)
            
            // .suffix(3) Take last 3 transactions in array
            // .reversed() newest action appears at the top
            ForEach(purchaseHistory.suffix(3).reversed()) { TransactionRow(transaction: $0) }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
        .padding(.horizontal)
    }

    // LOGIC
    
    // Sets inputted balance
    func setInitialBalance() {
        if let val = Double(balanceInput) {
            balance = val
            isBalanceSet = true
            hideKeyboard()
        }
    }

    // Deposit and withdrawal handler
    func processTransaction() {
      
        // Makes sure input is a valid number
        guard let amt = Double(amountInput), amt > 0 else { return }
        
        // Deposit Handler
        if selectedAction == .add {
            balance += amt
            purchaseHistory.append(Transaction(type: .deposit, amount: amt))
            alertMessage = "Deposited \(formatCurrency(amt))"
            
        // Withdraw Handler
        } else {
            if amt <= balance {
                balance -= amt
                purchaseHistory.append(Transaction(type: .withdrawal, amount: amt))
                alertMessage = "Withdrew \(formatCurrency(amt))"
            } else {
                alertMessage = "Insufficient funds!"
            }
        }
        selectedAction = nil
        amountInput = ""
        showingAlert = true
        hideKeyboard()
    }

    // Saves fee to memory
    func applyFee() {
        let feeToApply: Double
        
        if let newFee = Double(customFeeInput), newFee > 0 {
            // Update the permanent storage
            savedMonthlyFee = newFee
            feeToApply = newFee
        } else {
            // Use whatever was previously saved
            feeToApply = savedMonthlyFee
        }

        // Only fee withdraw if user can afford, and is a valid number
        if balance >= feeToApply {
            balance -= feeToApply
            purchaseHistory.append(Transaction(type: .fee, amount: feeToApply))
            alertMessage = "Fee of \(formatCurrency(feeToApply)) applied."
            customFeeInput = ""
            hideKeyboard()
        } else {
            alertMessage = "Not enough money for the fee."
        }
        showingAlert = true
    }

    // Converts double (input) to string for the UI (ex: 12.5 -> 12.50)
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
