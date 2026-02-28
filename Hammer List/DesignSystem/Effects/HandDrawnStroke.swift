import SwiftUI

// MARK: - Configuration
//
// The primary pivot point. Adjust these values to tune the look without
// touching any rendering implementation.

struct HandDrawnConfig {
    var color: Color
    var lineWidth: CGFloat
    var jitter: CGFloat     // max deviation from straight path, in points
    var segments: Int       // more segments = more granular wobble
    var passes: Int         // overlapping strokes (used by multi-pass renderer)
    var seed: UInt64        // change per-instance for unique variation

    static let `default` = HandDrawnConfig(
        color: .primary,
        lineWidth: 2.0,
        jitter: 1.5,
        segments: 10,
        passes: 2,
        seed: 1
    )
}

// MARK: - Seeded RNG
//
// Deterministic so the wobble doesn't change on every re-render.

private struct HandDrawnRNG {
    var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 6364136223846793005 : seed
    }

    mutating func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat(state >> 33) / CGFloat(UInt32.max)
    }
}

// MARK: - Core Shapes

/// A horizontal line with perpendicular jitter — use as a divider, underline, or decoration.
struct HandDrawnLine: Shape, Equatable {
    var jitter: CGFloat
    var segments: Int
    var seed: UInt64

    init(jitter: CGFloat = 1.5, segments: Int = 10, seed: UInt64 = 1) {
        self.jitter = jitter
        self.segments = segments
        self.seed = seed
    }

    func path(in rect: CGRect) -> Path {
        var rng = HandDrawnRNG(seed: seed)
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))

        for i in 1...max(segments, 1) {
            let t  = CGFloat(i) / CGFloat(segments)
            let x  = rect.minX + (rect.maxX - rect.minX) * t
            let dy = (rng.next() * 2 - 1) * jitter
            path.addLine(to: CGPoint(x: x, y: rect.midY + dy))
        }

        return path
    }
}

/// A rectangle border with perpendicular jitter on each edge — use in place of RoundedRectangle.stroke().
/// Jitter is applied only perpendicular to each edge so the wobble reads as hand-drawn, not chaotic.
struct HandDrawnRect: Shape, Equatable {
    var jitter: CGFloat = 0.8
    var segmentsPerEdge: Int = 3
    var seed: UInt64 = 1

    func path(in rect: CGRect) -> Path {
        var rng = HandDrawnRNG(seed: seed)
        var path = Path()

        func jv() -> CGFloat { (rng.next() * 2 - 1) * jitter }

        // Top-left start
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + jv()))

        // Top edge: left → right (jitter in y)
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            path.addLine(to: CGPoint(x: rect.minX + rect.width * t, y: rect.minY + jv()))
        }

        // Right edge: top → bottom (jitter in x)
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            path.addLine(to: CGPoint(x: rect.maxX + jv(), y: rect.minY + rect.height * t))
        }

        // Bottom edge: right → left (jitter in y)
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * t, y: rect.maxY + jv()))
        }

        // Left edge: bottom → top (jitter in x)
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            path.addLine(to: CGPoint(x: rect.minX + jv(), y: rect.maxY - rect.height * t))
        }

        path.closeSubpath()
        return path
    }
}

/// A rectangle border drawn as 4 disconnected strokes with corner overrun.
/// Each edge is an independent subpath so the corners don't perfectly meet —
/// exactly how you'd sketch a box by hand.
///
/// - `overrun`: how many points each stroke extends past the corner
struct HandDrawnRectStrokes: Shape, Equatable {
    var jitter: CGFloat = 1.2
    var segmentsPerEdge: Int = 4
    var overrun: CGFloat = 1.5
    var seed: UInt64 = 1

    func path(in rect: CGRect) -> Path {
        var rng = HandDrawnRNG(seed: seed)
        var path = Path()

        func jv() -> CGFloat { (rng.next() * 2 - 1) * jitter }

        let r = rect

        // ── Top edge: extends overrun past both corners, jitter in y ──
        path.move(to: CGPoint(x: r.minX - overrun, y: r.minY + jv()))
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            let x = r.minX - overrun + (r.width + overrun * 2) * t
            path.addLine(to: CGPoint(x: x, y: r.minY + jv()))
        }

        // ── Right edge: extends overrun past both corners, jitter in x ──
        path.move(to: CGPoint(x: r.maxX + jv(), y: r.minY - overrun))
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            let y = r.minY - overrun + (r.height + overrun * 2) * t
            path.addLine(to: CGPoint(x: r.maxX + jv(), y: y))
        }

        // ── Bottom edge: extends overrun past both corners, jitter in y ──
        path.move(to: CGPoint(x: r.maxX + overrun, y: r.maxY + jv()))
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            let x = r.maxX + overrun - (r.width + overrun * 2) * t
            path.addLine(to: CGPoint(x: x, y: r.maxY + jv()))
        }

        // ── Left edge: extends overrun past both corners, jitter in x ──
        path.move(to: CGPoint(x: r.minX + jv(), y: r.maxY + overrun))
        for i in 1...segmentsPerEdge {
            let t = CGFloat(i) / CGFloat(segmentsPerEdge)
            let y = r.maxY + overrun - (r.height + overrun * 2) * t
            path.addLine(to: CGPoint(x: r.minX + jv(), y: y))
        }

        // No closeSubpath() — each edge stays disconnected
        return path
    }
}

// MARK: - Renderer Protocol
//
// Swap the entire rendering engine by swapping the renderer.
// Add new conformers here without modifying existing code.

protocol HandDrawnRenderer {
    associatedtype Body: View
    @ViewBuilder func render(config: HandDrawnConfig) -> Body
}

// MARK: - Wobbly Renderer
//
// Single-pass. Lightweight and performant.

struct WobblyRenderer: HandDrawnRenderer {
    func render(config: HandDrawnConfig) -> some View {
        HandDrawnLine(jitter: config.jitter, segments: config.segments, seed: config.seed)
            .stroke(
                config.color,
                style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, lineJoin: .round)
            )
    }
}

// MARK: - Multi-pass Renderer
//
// Draws overlapping strokes at varying opacity and width.
// Mimics how graphite builds up unevenly on paper.

struct MultiPassRenderer: HandDrawnRenderer {
    func render(config: HandDrawnConfig) -> some View {
        let passes = max(config.passes, 1)

        return ZStack {
            ForEach(0..<passes, id: \.self) { pass in
                let t = passes > 1 ? CGFloat(pass) / CGFloat(passes - 1) : 1.0

                HandDrawnLine(
                    jitter: config.jitter * (1.3 - 0.6 * t),
                    segments: config.segments,
                    seed: config.seed + UInt64(pass)
                )
                .stroke(
                    config.color.opacity(0.35 + 0.65 * t),
                    style: StrokeStyle(
                        lineWidth: config.lineWidth * (1.4 - 0.8 * t),
                        lineCap: .round
                    )
                )
                .offset(y: (CGFloat(pass) - CGFloat(passes - 1) / 2.0) * 0.5)
            }
        }
    }
}

// MARK: - Type-erased Renderer
//
// Lets call sites hold any renderer without knowing its concrete type,
// making it easy to accept renderers as parameters or store in state.

struct AnyHandDrawnRenderer {
    private let _render: (HandDrawnConfig) -> AnyView

    init<R: HandDrawnRenderer>(_ renderer: R) {
        _render = { AnyView(renderer.render(config: $0)) }
    }

    func render(config: HandDrawnConfig) -> AnyView {
        _render(config)
    }
}

extension AnyHandDrawnRenderer {
    static let wobbly    = AnyHandDrawnRenderer(WobblyRenderer())
    static let multiPass = AnyHandDrawnRenderer(MultiPassRenderer())
}

// MARK: - PencilStroke View
//
// Standalone stroke. Use anywhere a line is needed:
// as a divider, decoration, underline, or separator.
//
// Example:
//   PencilStroke()
//   PencilStroke(config: .init(color: .orange, lineWidth: 3))
//   PencilStroke(renderer: .wobbly)

struct PencilStroke: View {
    var config: HandDrawnConfig
    var renderer: AnyHandDrawnRenderer

    init(
        config: HandDrawnConfig = .default,
        renderer: AnyHandDrawnRenderer = .multiPass
    ) {
        self.config = config
        self.renderer = renderer
    }

    var body: some View {
        renderer.render(config: config)
            .frame(height: config.lineWidth + config.jitter * 2 + 4)
    }
}

// MARK: - View Extensions

extension View {
    /// Adds a hand-drawn underline beneath the view.
    func handDrawnUnderline(
        config: HandDrawnConfig = .default,
        renderer: AnyHandDrawnRenderer = .multiPass
    ) -> some View {
        VStack(spacing: 2) {
            self
            PencilStroke(config: config, renderer: renderer)
        }
    }
}

// MARK: - Preview

#Preview("PencilStroke Styles") {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Wobbly (single-pass)")
                .font(.caption)
                .foregroundStyle(.secondary)
            PencilStroke(renderer: .wobbly)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Multi-pass")
                .font(.caption)
                .foregroundStyle(.secondary)
            PencilStroke(renderer: .multiPass)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Heavy jitter")
                .font(.caption)
                .foregroundStyle(.secondary)
            PencilStroke(config: .init(color: .primary, lineWidth: 3, jitter: 3, segments: 12, passes: 3, seed: 42))
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("handDrawnUnderline modifier")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Shopping List")
                .font(.title2.bold())
                .handDrawnUnderline(config: .init(color: .orange, lineWidth: 2, jitter: 1.5, segments: 14, passes: 2, seed: 7))
        }
    }
    .padding(24)
}
