import SwiftUI

struct DraggableSplitView<TopContent: View, BottomContent: View>: View {
    @State private var topHeightRatio: CGFloat
    private let minHeightRatio: CGFloat
    private let maxHeightRatio: CGFloat

    // iPhone frame constants (matching Figma design)
    private let framePadding: CGFloat = 12
    private let panelGap: CGFloat = 12
    private let dividerTouchHeight: CGFloat = 28  // touch target
    private let homeIndicatorWidth: CGFloat = 81
    private let homeIndicatorHeight: CGFloat = 7
    private let panelCornerRadius: CGFloat = 20

    let topContent: () -> TopContent
    let bottomContent: () -> BottomContent

    init(initialTopRatio: CGFloat = 0.4,
         minTopRatio: CGFloat = 0.2,
         maxTopRatio: CGFloat = 0.8,
         @ViewBuilder topContent: @escaping () -> TopContent,
         @ViewBuilder bottomContent: @escaping () -> BottomContent) {
        self._topHeightRatio = State(initialValue: initialTopRatio)
        self.minHeightRatio = minTopRatio
        self.maxHeightRatio = maxTopRatio
        self.topContent = topContent
        self.bottomContent = bottomContent
    }

    var body: some View {
        GeometryReader { geometry in
            // Available height after frame padding, gaps, and divider touch area
            let totalChrome = (framePadding * 2) + (panelGap * 2) + dividerTouchHeight
            let availableHeight = geometry.size.height - totalChrome
            let topHeight = availableHeight * topHeightRatio
            let bottomHeight = availableHeight * (1 - topHeightRatio)

            VStack(spacing: panelGap) {
                // Top panel — white rounded screen area
                topContent()
                    .frame(maxWidth: .infinity)
                    .frame(height: topHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: panelCornerRadius))

                // Home indicator — draggable divider
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: dividerTouchHeight)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: homeIndicatorWidth, height: homeIndicatorHeight)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dragRatio = value.translation.height / availableHeight
                            let newRatio = topHeightRatio + dragRatio
                            topHeightRatio = min(max(newRatio, minHeightRatio), maxHeightRatio)
                        }
                )

                // Bottom panel — white rounded screen area
                bottomContent()
                    .frame(maxWidth: .infinity)
                    .frame(height: bottomHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: panelCornerRadius))
            }
            .padding(framePadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "4C4C4C"))
        }
        .frame(maxHeight: .infinity)
    }
}
