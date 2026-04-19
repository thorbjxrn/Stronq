import SwiftUI

struct BarbellGlyph: View {
    var color: Color = .white
    var height: CGFloat = 28

    var body: some View {
        HStack(spacing: 0) {
            // Left collar
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.3))
                .frame(width: 8, height: 3)

            // Left plates — small change plate then 3 big plates
            HStack(spacing: 1.5) {
                plate(ratio: 0.45)
                plate(ratio: 1.0)
                plate(ratio: 1.0)
                plate(ratio: 1.0)
            }

            // Bar
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.3))
                .frame(width: 40, height: 3)

            // Right plates — 3 big plates then small change plate
            HStack(spacing: 1.5) {
                plate(ratio: 1.0)
                plate(ratio: 1.0)
                plate(ratio: 1.0)
                plate(ratio: 0.45)
            }

            // Right collar
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.3))
                .frame(width: 8, height: 3)
        }
    }

    private func plate(ratio: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: 4, height: height * ratio)
    }
}
