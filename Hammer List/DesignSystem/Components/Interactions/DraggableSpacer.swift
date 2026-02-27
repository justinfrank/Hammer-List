import SwiftUI

struct DraggableSplitView<TopContent: View, BottomContent: View>: View {
    @State private var topHeightRatio: CGFloat
    @GestureState private var dragOffset: CGFloat = 0

    private let minHeightRatio: CGFloat
    private let maxHeightRatio: CGFloat
    private let dividerHeight: CGFloat = 28
    private let sectionGap: CGFloat = AppTokens.Spacing._100

    let topContent: () -> TopContent
    let bottomContent: () -> BottomContent

    init(
        initialTopRatio: CGFloat = 0.4,
        minTopRatio: CGFloat = 0.2,
        maxTopRatio: CGFloat = 0.8,
        @ViewBuilder topContent: @escaping () -> TopContent,
        @ViewBuilder bottomContent: @escaping () -> BottomContent
    ) {
        self._topHeightRatio = State(initialValue: initialTopRatio)
        self.minHeightRatio = minTopRatio
        self.maxHeightRatio = maxTopRatio
        self.topContent = topContent
        self.bottomContent = bottomContent
    }

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - dividerHeight - sectionGap
            let committedRatio = min(
                max(topHeightRatio + dragOffset / availableHeight, minHeightRatio),
                maxHeightRatio
            )
            let topHeight = availableHeight * committedRatio
            let bottomHeight = availableHeight * (1 - committedRatio)

            VStack(spacing: sectionGap) {
                // Top card
                topContent()
                    .frame(maxWidth: .infinity)
                    .frame(height: topHeight)
                    .background(
                        RoundedRectangle(cornerRadius: AppTokens.CornerRadius.large)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTokens.CornerRadius.large))

                // Bottom card with drag handle
                VStack(spacing: 0) {
                    // Drag handle
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                        Capsule()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 48, height: 4)
                    }
                    .frame(height: dividerHeight)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.height
                            }
                            .onEnded { value in
                                let dragRatio = value.translation.height / availableHeight
                                topHeightRatio = min(
                                    max(topHeightRatio + dragRatio, minHeightRatio),
                                    maxHeightRatio
                                )
                            }
                    )

                    // Bottom content
                    bottomContent()
                        .frame(maxWidth: .infinity)
                        .frame(height: bottomHeight)
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTokens.CornerRadius.large)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTokens.CornerRadius.large))
            }
        }
        .frame(maxHeight: .infinity)
    }
}
