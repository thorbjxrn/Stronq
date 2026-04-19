import SwiftUI

struct BarbellGlyph: View {
    var color: Color = .white
    var height: CGFloat = 28

    var body: some View {
        HStack(spacing: 2) {
            plate(width: 4, ratio: 0.7)
            plate(width: 4, ratio: 0.85)
            plate(width: 4, ratio: 1.0)
            plate(width: 4, ratio: 1.0)

            bar

            plate(width: 4, ratio: 1.0)
            plate(width: 4, ratio: 1.0)
            plate(width: 4, ratio: 0.85)
            plate(width: 4, ratio: 0.7)
        }
    }

    private func plate(width: CGFloat, ratio: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: width, height: height * ratio)
    }

    private var bar: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color.opacity(0.4))
            .frame(width: 24, height: 3)
    }
}
