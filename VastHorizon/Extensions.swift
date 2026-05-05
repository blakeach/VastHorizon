// Extensions.swift

import SwiftUI

extension Color {
    init(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

extension Double {
    var currency: String { CurrencyFormatter.format(self) }
}

extension Date {
    /// Returns true if self and other fall on the same calendar day.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Number of full days between self and other (absolute value).
    func daysDifference(from other: Date) -> Int {
        let comps = Calendar.current.dateComponents([.day], from: other, to: self)
        return abs(comps.day ?? 0)
    }
}
