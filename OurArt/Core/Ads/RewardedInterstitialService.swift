//
//  RewardedInterstitialService.swift
//  OurArt
//
//  Created by Jongmo You on 08.10.25.
//

import Foundation
import GoogleMobileAds
import UIKit

protocol AdService {
    func preloadAd() async
    func presentAd() async -> Bool
}

final class RewardedInterstitialService: NSObject, FullScreenContentDelegate {
    static let shared = RewardedInterstitialService()
    private override init() {}

    private var ad: RewardedInterstitialAd?
    private let adUnitId = "ca-app-pub-3940256099942544/6978759866" // AdMob 테스트용 보상형 전면광고 ID
    private let dayKey = "support.rewarded.day"
    private let countKey = "support.rewarded.count"
    private let dailyLimit = 5
    private var onDismiss: ((Bool) -> Void)?

    // MARK: - Public
    func currentCount() -> Int {
        resetIfNewDay()
        return UserDefaults.standard.integer(forKey: countKey)
    }

    func canShowToday() -> Bool {
        currentCount() < dailyLimit
    }
    
    func preloadAd() async {
        resetIfNewDay()
        guard canShowToday() else { return }
        
        do {
            try await loadIfNeeded()
            print("보상형 전면광고 미리 로드 완료")
        } catch {
            ad = nil
            print("보상형 전면광고 로드 실패: \(error)")
        }
    }
    
    // 광고를 보여주고, 사용자가 보상을 획득하면 카운트를 +1
    @discardableResult
    func presentIfAllowedAndIncrement() async -> Bool {
        resetIfNewDay()
        guard canShowToday() else { return false }
        
        // 이미 로드된 광고가 없으면 즉시 로드 시도
        if ad == nil {
            do {
                try await loadIfNeeded()
            } catch {
                ad = nil
                return false
            }
        }
        
        guard let ad else { return false }
        
        var didEarnReward = false
        ad.fullScreenContentDelegate = self
        
        await ad.present(from: nil) {
            didEarnReward = true
        }
        
        let earned = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            self.onDismiss = { didEarn in
                cont.resume(returning: didEarn)
            }
        }
        
        self.ad = nil
        if earned {
            incrementCount()
            // 광고 표시 후 다음 광고 미리 로드
            Task {
                await preloadAd()
            }
        }
        return earned
    }

    // MARK: - Private
    private func loadIfNeeded() async throws {
        if ad != nil { return }
        ad = try await RewardedInterstitialAd.load(with: adUnitId, request: Request())
    }

    private func incrementCount() {
        let count = currentCount()
        UserDefaults.standard.set(count + 1, forKey: countKey)
    }

    private func resetIfNewDay() {
        let today = Self.todayString()
        let savedDay = UserDefaults.standard.string(forKey: dayKey)
        if savedDay != today {
            UserDefaults.standard.set(today, forKey: dayKey)
            UserDefaults.standard.set(0, forKey: countKey)
        }
    }

    private static func todayString() -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        if let onDismiss {
            onDismiss(true)
        }
        self.onDismiss = nil
    }
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        onDismiss?(false)
        onDismiss = nil
    }
}


class RewardedInterstitialViewModel: ObservableObject {
    func presentIfAllowedAndIncrement() async -> Bool {
        return await RewardedInterstitialService.shared.presentIfAllowedAndIncrement()
    }
    
    func currentCount() -> Int {
        return RewardedInterstitialService.shared.currentCount()
    }
    
    func preloadAd() async {
        await RewardedInterstitialService.shared.preloadAd()
    }
}
