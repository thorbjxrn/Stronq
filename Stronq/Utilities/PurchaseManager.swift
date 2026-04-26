import StoreKit
import SwiftUI

@Observable
@MainActor
final class PurchaseManager {
    private(set) var isPremium: Bool = false
    private(set) var products: [Product] = []
    private(set) var purchaseError: String?

    var priceDisplay: String {
        products.first?.displayPrice ?? "$4.99"
    }

    private static let productID = "com.thorbjxrn.stronq.premium"
    private var transactionListener: Task<Void, Never>?

    init() {
        #if DEBUG
        isPremium = true
        #else
        isPremium = UserDefaults.standard.bool(forKey: "isPremiumCached")
        #endif
        transactionListener = listenForTransactions()
        Task { await verifyEntitlement() }
    }

    nonisolated deinit {
        // transactionListener is cancelled automatically when the Task is deallocated
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.productID])
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product = products.first else {
            await loadProducts()
            guard let product = products.first else { return }
            await purchaseProduct(product)
            return
        }
        await purchaseProduct(product)
    }

    private func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    isPremium = true
                    UserDefaults.standard.set(true, forKey: "isPremiumCached")
                    try await verification.payloadValue.finish()
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await verifyEntitlement()
    }

    func verifyEntitlement() async {
        guard let result = await Transaction.currentEntitlement(for: Self.productID) else {
            isPremium = false
            UserDefaults.standard.set(false, forKey: "isPremiumCached")
            return
        }
        if case .verified = result {
            isPremium = true
            UserDefaults.standard.set(true, forKey: "isPremiumCached")
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { @MainActor [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    self?.isPremium = true
                    UserDefaults.standard.set(true, forKey: "isPremiumCached")
                    await transaction.finish()
                }
            }
        }
    }

    #if DEBUG
    func debugTogglePremium() {
        isPremium.toggle()
        UserDefaults.standard.set(isPremium, forKey: "isPremiumCached")
    }
    #endif
}
