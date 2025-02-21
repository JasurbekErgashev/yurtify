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
            ForEach(0 ..< 12) { index in
                SparkleRay(color: .yellow)
                    .rotationEffect(.degrees(Double(index) * 30 + rotation))
            }

            // Inner sparkles
            ForEach(0 ..< 8) { index in
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
