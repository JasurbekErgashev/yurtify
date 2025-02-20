import SwiftUI

struct CategoryPill: View {
    let category: Category
    var style: Style = .filled

    enum Style {
        case filled
        case outlined
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(category.icon)
                .font(.subheadline)
            Text(category.rawValue)
                .font(style == .filled ? .subheadline : .caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, style == .filled ? 12 : 8)
        .padding(.vertical, style == .filled ? 6 : 4)
        .background(style == .filled ? category.color : category.color.opacity(0.15))
        .foregroundStyle(style == .filled ? .white : category.color)
        .clipShape(Capsule())
    }
}
