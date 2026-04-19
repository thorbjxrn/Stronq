import SwiftUI

struct LaunchBurstView: View {
    let theme: ThemeManager
    let onFinish: () -> Void

    @State private var ringScale: CGFloat = 0
    @State private var ringOpacity: Double = 1
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var bgBrightness: Double = 0
    @State private var pulseScale: CGFloat = 1
    @State private var exitOpacity: Double = 1
    @State private var exitScale: CGFloat = 1

    var body: some View {
        ZStack {
            theme.backgroundColor
                .brightness(bgBrightness)
                .ignoresSafeArea()

            Circle()
                .strokeBorder(theme.accentColor, lineWidth: 3)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            Circle()
                .strokeBorder(theme.accentColor.opacity(0.4), lineWidth: 2)
                .scaleEffect(ringScale * 0.7)
                .opacity(ringOpacity)

            VStack(spacing: 20) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(theme.accentColor)
                    .scaleEffect(iconScale)
                    .scaleEffect(pulseScale)
                    .opacity(iconOpacity)

                VStack(spacing: 8) {
                    Text("Stronq")
                        .font(Typo.title)

                    Text("Let's lift.")
                        .font(Typo.body)
                        .foregroundStyle(theme.textSecondary)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
            .scaleEffect(exitScale)
        }
        .opacity(exitOpacity)
        .onAppear {
            // Ring burst
            withAnimation(.easeOut(duration: 0.6)) {
                ringScale = 4
                ringOpacity = 0
            }

            // Background flash
            withAnimation(.easeOut(duration: 0.2)) {
                bgBrightness = 0.08
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                bgBrightness = 0
            }

            // Icon pop
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) {
                iconScale = 1
                iconOpacity = 1
            }

            // Icon pulse
            withAnimation(.easeInOut(duration: 0.8).delay(0.7).repeatCount(2, autoreverses: true)) {
                pulseScale = 1.08
            }

            // Text slide up
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                textOpacity = 1
                textOffset = 0
            }

            // Exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    exitOpacity = 0
                    exitScale = 1.1
                }
            }

            // Dismiss after exit completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinish()
            }
        }
    }
}
