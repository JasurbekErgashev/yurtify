import SwiftUI

struct FloatingCollectibleButton: View {
    let collectible: Collectible
    @Binding var isCollected: Bool
    @State private var isShowingDetails = false
    @State private var animationScale = 1.0
    @EnvironmentObject private var progressManager: UserProgressManager

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isShowingDetails = true
            }
        } label: {
            Text(collectible.category.icon)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                }
                .overlay {
                    SparkleView()
                        .opacity(isCollected ? 0 : 1)
                }
        }
        .scaleEffect(animationScale)
        .sheet(isPresented: $isShowingDetails, onDismiss: {
            withAnimation {
                isCollected = true
                progressManager.recordCollectible(collectible.id, points: collectible.points)
            }
        }) {
            CollectibleFoundView(collectible: collectible)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                animationScale = 1.05
            }
        }
    }
}

struct SparkleView: View {
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var opacity = 0.8

    var body: some View {
        ZStack {
            // Outer sparkles
            ForEach(0..<12) { index in
                SparkleRay(color: .yellow)
                    .rotationEffect(.degrees(Double(index) * 30 + rotation))
            }
            
            // Inner sparkles
            ForEach(0..<8) { index in
                SparkleRay(color: .white)
                    .rotationEffect(.degrees(Double(index) * 45 - rotation))
                    .scaleEffect(0.7)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                scale = 1.1
                opacity = 1
            }
        }
    }
}

struct SparkleRay: View {
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [color.opacity(0.8), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 2, height: 20)
            .offset(y: -35)
            .blur(radius: 0.5)
    }
}

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
