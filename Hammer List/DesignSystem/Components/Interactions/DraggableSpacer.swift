import SwiftUI

struct DraggableSplitView<TopContent: View, BottomContent: View>: View {
    @State private var topHeightRatio: CGFloat
    private let minHeightRatio: CGFloat
    private let maxHeightRatio: CGFloat
    private let dividerHeight: CGFloat = 28 // Height of divider + padding
    
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
            let availableHeight = geometry.size.height - dividerHeight
            let topHeight = availableHeight * topHeightRatio
            let bottomHeight = availableHeight * (1 - topHeightRatio)
            
            VStack(spacing: 0) {
                // Top panel with custom content
                HStack {
                    topContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: topHeight)

                // Group divider and bottom panel inside a ZStack with background
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
//                        .fill(LightTheme.accent)
                        .fill(Color.secondary.opacity(0.2))
                    VStack(spacing: 0) {
                        // Draggable divider
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 12)
//                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                            HStack(spacing: 4) {
                                Capsule()
                                    .fill(Color.secondary)
                                    .frame(width: 48, height: 4)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 8)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragRatio = value.translation.height / availableHeight
                                    let newRatio = topHeightRatio + dragRatio
                                    topHeightRatio = min(max(newRatio, minHeightRatio), maxHeightRatio)
                                }
                        )
                        // Bottom panel with custom content
                        HStack {
                            bottomContent()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: bottomHeight)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .border(Color.gray.opacity(0.3))
    }
}
