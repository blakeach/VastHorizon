// Grid of all badges — unlocked ones glow, locked ones are dimmed silhouettes.

import SwiftUI

struct BadgesView: View {

    let profile: PlayerProfile

    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Player stats summary
                        statsStrip

                        // Badge grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Badge.allCases) { badge in
                                BadgeCard(
                                    badge:    badge,
                                    unlocked: profile.earnedBadgeIDs.contains(badge.rawValue)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Achievements")
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

    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(value: "\(profile.level)",          label: "Level")
            Divider().frame(height: 36).background(Color.white.opacity(0.1))
            statCell(value: "\(profile.xp)",             label: "Total XP")
            Divider().frame(height: 36).background(Color.white.opacity(0.1))
            statCell(value: "\(profile.longestStreak)d", label: "Best Streak")
            Divider().frame(height: 36).background(Color.white.opacity(0.1))
            statCell(value: "\(profile.earnedBadgeIDs.count)/\(Badge.allCases.count)", label: "Badges")
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    var profile = PlayerProfile()
    profile.level = 4
    profile.xp = 350
    profile.currentStreak = 5
    profile.longestStreak = 9
    profile.earnedBadgeIDs = [Badge.firstDeposit.rawValue, Badge.weekStreak.rawValue]
    return BadgesView(profile: profile)
}
