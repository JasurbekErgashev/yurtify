import Foundation

extension Int {
    var formattedWithSpaces: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
