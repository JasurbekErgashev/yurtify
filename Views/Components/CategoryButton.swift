import SwiftUI

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(category.icon)
                    .font(.subheadline)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color.opacity(0.15) : .gray.opacity(0.1))
            .foregroundStyle(isSelected ? category.color : .secondary)
            .clipShape(Capsule())
        }
    }
}
