import SwiftUI

@Observable
@MainActor
final class AdManager {
    private let purchaseManager: PurchaseManager
    private(set) var isShowingInterstitial = false
    private var appOpenCount: Int
    private var sessionCompletionCount: Int

    private let gracePeriodOpens = 3
    private let interstitialFrequency = 3

    var shouldShowAds: Bool {
        !purchaseManager.isPremium && appOpenCount > gracePeriodOpens
    }

    var shouldShowBanner: Bool { shouldShowAds }

    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
        self.appOpenCount = UserDefaults.standard.integer(forKey: "appOpenCount")
        self.sessionCompletionCount = UserDefaults.standard.integer(forKey: "sessionCompletionCount")
    }

    func recordAppOpen() {
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: "appOpenCount")
    }

    func recordSessionCompletion() {
        guard shouldShowAds else { return }
        sessionCompletionCount += 1
        UserDefaults.standard.set(sessionCompletionCount, forKey: "sessionCompletionCount")
        if sessionCompletionCount % interstitialFrequency == 0 {
            showInterstitial()
        }
    }

    private func showInterstitial() {
        isShowingInterstitial = true
    }

    func dismissInterstitial() {
        isShowingInterstitial = false
    }
}
