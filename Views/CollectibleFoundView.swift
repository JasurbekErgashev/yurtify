import SwiftUI

struct CollectibleFoundView: View {
    let collectible: Collectible
    @Environment(\.dismiss) private var dismiss
    @State private var textScale = 1.0
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 32) {
            // Main content
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)

                Text("Woohoo! You found something!")
                    .font(.title2)
                    .fontWeight(.bold)

                // Animated collectible name
                Text(collectible.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .scaleEffect(textScale)
                    .opacity(showDetails ? 1 : 0)
                    .offset(y: showDetails ? 0 : 20)
            }

            // Points and rarity
            VStack(spacing: 16) {
                Label("\(collectible.points) XP", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())

                HStack {
                    Circle()
                        .fill(collectible.rarity.color)
                        .frame(width: 8, height: 8)
                    Text(collectible.rarity.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(showDetails ? 1 : 0)
            .offset(y: showDetails ? 0 : 20)

            // Description
            if showDetails {
                Text(collectible.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button("Awesome!") {
                dismiss()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.vertical)
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.4)) {
                showDetails = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                textScale = 1.1
            }
        }
    }
}
