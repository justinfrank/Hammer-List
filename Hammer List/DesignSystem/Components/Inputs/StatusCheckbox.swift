import SwiftUI

struct StatusCheckbox: View {
    let status: TodoStatus
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cornerRadius: CGFloat = 4
            ZStack {
                // 4 disconnected strokes with corner overrun — looks hand-sketched
                HandDrawnRectStrokes(jitter: 1.2, segmentsPerEdge: 4, overrun: 1.5, seed: 12)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                    )
                switch status {
                case .notStarted:
                    EmptyView()
                case .inProgress:
                    // Blue fill upper right half (rotated 270 degrees from original)
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.clear)
                        Path { path in
                            // Draw a triangle covering the upper right half
                            path.move(to: CGPoint(x: size, y: 0))
                            path.addLine(to: CGPoint(x: size, y: size))
                            path.addLine(to: CGPoint(x: 0, y: size))
                            path.closeSubpath()
                        }
                        .fill(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                case .completed:
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.green)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: size * 0.6, weight: .bold))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusCheckbox(status: .notStarted)
            .frame(width: 18, height: 18)
        StatusCheckbox(status: .inProgress)
            .frame(width: 18, height: 18)
        StatusCheckbox(status: .completed)
            .frame(width: 18, height: 18)
    }
} 