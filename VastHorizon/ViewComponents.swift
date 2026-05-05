// ViewComponents.swift
// Reusable UI components: buttons, rows, XP bar, streak chip, badge card.

import SwiftUI

// MARK: - ActionButton

struct ActionButton: View {
    let title:      String
    let color:      Color
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? color : color.opacity(0.15))
                )
        }
    }
}

// MARK: - TransactionRow

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(transaction.type.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: transaction.type.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.type.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.type.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(transaction.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transaction.signedAmount)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(transaction.type.color)
                if transaction.xpEarned > 0 {
                    Text("+\(transaction.xpEarned) XP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "F39C12"))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - XPBar

struct XPBar: View {
    let profile: PlayerProfile

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Label("Level \(profile.level)", systemImage: "bolt.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "F39C12"))
                Spacer()
                Text("\(profile.xp) / \(profile.xpForNextLevel) XP")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F39C12"), Color(hex: "E74C3C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * profile.levelProgress, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: profile.levelProgress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - StreakChip

struct StreakChip: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundColor(streak > 0 ? Color(hex: "E74C3C") : .gray)
            Text(streak > 0 ? "\(streak) day streak" : "No streak")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(streak > 0 ? .white : .gray)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(streak > 0 ? Color(hex: "E74C3C").opacity(0.15) : Color.white.opacity(0.05))
        )
    }
}

// MARK: - BalanceMeter

struct BalanceMeter: View {
    let balance: Double
    var ceiling: Double = 10_000

    private var progress: Double { min(balance / ceiling, 1.0) }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(135))

            Circle()
                .trim(from: 0, to: 0.75 * progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "E74C3C"), Color(hex: "F39C12"), Color(hex: "27AE60")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
        }
        .frame(width: 140, height: 140)
    }
}

// MARK: - BadgeCard

struct BadgeCard: View {
    let badge:    Badge
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? badge.color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                Image(systemName: badge.icon)
                    .font(.system(size: 24))
                    .foregroundColor(unlocked ? badge.color : Color.white.opacity(0.2))
            }
            Text(badge.title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(unlocked ? .white : Color.white.opacity(0.25))
                .multilineTextAlignment(.center)
            Text(badge.description)
                .font(.system(size: 9))
                .foregroundColor(unlocked ? .gray : Color.white.opacity(0.15))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 110)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(unlocked ? Color.white.opacity(0.06) : Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(unlocked ? badge.color.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .grayscale(unlocked ? 0 : 1)
        .opacity(unlocked ? 1 : 0.4)
    }
}

// MARK: - LevelUpOverlay

struct LevelUpOverlay: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 20) {
                // Pulsing star
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "F39C12"))
                    .symbolEffect(.pulse)

                Text("LEVEL UP!")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "F39C12"))
                    .tracking(4)

                Text(message)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Button("Continue") { onDismiss() }
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color(hex: "F39C12"))
                    .cornerRadius(14)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "0A1628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(hex: "F39C12").opacity(0.4), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - NewBadgeOverlay

struct NewBadgeOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(badge.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    Image(systemName: badge.icon)
                        .font(.system(size: 46))
                        .foregroundColor(badge.color)
                        .symbolEffect(.bounce)
                }

                Text("BADGE UNLOCKED")
                    .font(.caption.bold().monospaced())
                    .tracking(3)
                    .foregroundColor(badge.color)

                Text(badge.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text(badge.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                if badge.xpReward > 0 {
                    Text("+\(badge.xpReward) XP")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "F39C12"))
                }

                Button("Claim") { onDismiss() }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(badge.color)
                    .cornerRadius(14)
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "0A1628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(badge.color.opacity(0.4), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
