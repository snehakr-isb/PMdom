import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let isActive: Bool

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
        }
        .onChange(of: isActive) { _, active in
            if active { burst() }
        }
    }

    private func burst() {
        particles = (0..<40).map { _ in ConfettiParticle() }
        withAnimation(.easeOut(duration: 1.2)) {
            for i in particles.indices {
                particles[i].y -= CGFloat.random(in: 80...200)
                particles[i].x += CGFloat.random(in: -120...120)
                particles[i].opacity = 0
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat = 0
    var y: CGFloat = 0
    var size: CGFloat = CGFloat.random(in: 6...12)
    var opacity: Double = 1
    var color: Color = [Color.yellow, .orange, .pink, .purple, .blue, .green].randomElement()!
}
