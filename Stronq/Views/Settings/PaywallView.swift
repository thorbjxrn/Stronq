import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var theme
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(theme.accentColor)

                    Text("Stronq Premium")
                        .font(Typo.title)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("Yoked program (3 exercises)", icon: "figure.strengthtraining.traditional")
                        featureRow("Exercise swapping", icon: "arrow.triangle.2.circlepath")
                        featureRow("7 premium themes", icon: "paintpalette")
                        featureRow("Future programs & features", icon: "star")
                    }
                    .padding()
                    .background(theme.cardColor, in: RoundedRectangle(cornerRadius: 12))

                    Spacer()

                    Button {
                        isPurchasing = true
                        Task {
                            await purchaseManager.purchase()
                            isPurchasing = false
                            if purchaseManager.isPremium {
                                dismiss()
                            }
                        }
                    } label: {
                        Group {
                            if isPurchasing {
                                SwiftUI.ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Upgrade — \(purchaseManager.priceDisplay)")
                                    .font(Typo.heading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.accentColor)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isPurchasing)

                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(Typo.body)
                    .foregroundStyle(theme.textSecondary)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear {
            Task { await purchaseManager.loadProducts() }
        }
    }

    private func featureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(theme.accentColor)
                .frame(width: 24)
            Text(text)
        }
    }
}
