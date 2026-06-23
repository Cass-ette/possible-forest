import SwiftUI

struct PetCharacterView: View {
    let stage: PetStage
    let mood: PetMood
    @State private var bob: Bool = false
    @State private var blink: Bool = false

    var body: some View {
        ZStack {
            shadow
            bodyGroup
                .scaleEffect(stage.scale)
                .offset(y: bob ? -6 : 6)
                .animation(.spring(response: 2.2, dampingFraction: 0.55).repeatForever(autoreverses: true), value: bob)
        }
        .onAppear {
            bob = true
            scheduleBlink()
        }
    }

    private var shadow: some View {
        Ellipse()
            .fill(.black.opacity(0.12))
            .frame(width: 130, height: 22)
            .blur(radius: 6)
            .offset(y: 100)
    }

    @ViewBuilder
    private var bodyGroup: some View {
        ZStack {
            bodyShape
            bodyHighlight
            sprout
                .offset(y: -108)
            face
        }
    }

    private var bodyShape: some View {
        Ellipse()
            .fill(
                .radialGradient(
                    stops: [
                        .init(color: Theme.petSecondary, location: 0.15),
                        .init(color: Theme.petPrimary, location: 1.0)
                    ],
                    center: .center,
                    startRadius: 8,
                    endRadius: 110
                )
            )
            .frame(width: 168, height: 184)
            .overlay(
                Ellipse()
                    .stroke(.white.opacity(0.45), lineWidth: 2)
                    .frame(width: 168, height: 184)
            )
    }

    private var bodyHighlight: some View {
        Ellipse()
            .fill(.white.opacity(0.5))
            .frame(width: 42, height: 60)
            .rotationEffect(.degrees(-15))
            .offset(x: -34, y: -42)
    }

    @ViewBuilder
    private var sprout: some View {
        if stage == .seed {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Theme.petAccent.opacity(0.85))
                        .frame(width: 6, height: 30)
                        .cornerRadius(3)
                    Ellipse()
                        .fill(Theme.petLeaf)
                        .frame(width: 30, height: 16)
                        .rotationEffect(.degrees(-30))
                        .offset(x: -12, y: -6)

                    if stage == .young || stage == .adult {
                        Ellipse()
                            .fill(Theme.petLeaf)
                            .frame(width: 26, height: 14)
                            .rotationEffect(.degrees(30))
                            .offset(x: 14, y: -16)
                    }

                    if stage == .adult {
                        ZStack {
                            ForEach(0..<5, id: \.self) { i in
                                PetalShape()
                                    .fill([.pink, .yellow, .orange, .purple, .red][i])
                                    .frame(width: 14, height: 22)
                                    .rotationEffect(.degrees(Double(i) * 72))
                            }
                            Circle().fill(.yellow).frame(width: 10, height: 10)
                        }
                        .offset(y: -22)
                    }
                }
            }
        }
    }

    private var face: some View {
        VStack(spacing: 14) {
            HStack(spacing: 28) {
                eye
                eye
            }
            mouth
        }
        .offset(y: -4)
    }

    @ViewBuilder
    private var eye: some View {
        if blink || mood == .sleepy {
            Capsule()
                .fill(Theme.textPrimary)
                .frame(width: 14, height: 4)
        } else if mood == .happy || mood == .celebrating {
            ArcShape(start: .degrees(20), end: .degrees(160), clockwise: true)
                .stroke(Theme.textPrimary, style: .init(lineWidth: 4, lineCap: .round))
                .frame(width: 18, height: 12)
        } else {
            ZStack {
                Circle().fill(Theme.textPrimary).frame(width: 14, height: 14)
                Circle().fill(.white).frame(width: 4, height: 4).offset(x: -3, y: -3)
            }
        }
    }

    @ViewBuilder
    private var mouth: some View {
        switch mood {
        case .celebrating:
            ArcShape(start: .degrees(0), end: .degrees(180))
                .fill(Theme.textPrimary)
                .frame(width: 22, height: 14)
        case .happy:
            ArcShape(start: .degrees(0), end: .degrees(180))
                .stroke(Theme.textPrimary, style: .init(lineWidth: 3, lineCap: .round))
                .frame(width: 20, height: 12)
        case .sleepy:
            Capsule().fill(Theme.textPrimary).frame(width: 12, height: 3).opacity(0.6)
        case .encouraging:
            ArcShape(start: .degrees(0), end: .degrees(180))
                .stroke(Theme.textPrimary, style: .init(lineWidth: 3, lineCap: .round))
                .frame(width: 16, height: 9)
        case .thoughtful:
            Capsule().fill(Theme.textPrimary).frame(width: 12, height: 3).rotationEffect(.degrees(-5))
        case .neutral:
            Capsule().fill(Theme.textPrimary).frame(width: 14, height: 3)
        }
    }

    private func scheduleBlink() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Double.random(in: 2.5...4.5)))
            withAnimation(.easeInOut(duration: 0.1)) { blink = true }
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.easeInOut(duration: 0.1)) { blink = false }
            scheduleBlink()
        }
    }
}

struct ArcShape: Shape {
    var start: Angle
    var end: Angle
    var clockwise: Bool = false

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                 radius: min(rect.width, rect.height) / 2,
                 startAngle: start,
                 endAngle: end,
                 clockwise: clockwise)
        return p
    }
}

struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                       control: CGPoint(x: rect.maxX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.minX, y: rect.midY))
        return p
    }
}
