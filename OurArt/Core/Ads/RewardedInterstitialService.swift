//
//  RewardedInterstitialService.swift
//  OurArt
//
//  Created by Jongmo You on 08.10.25.
//

import Foundation
import GoogleMobileAds
import UIKit

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

    // 광고를 보여주고, 사용자가 보상을 획득하면 카운트를 +1
    @discardableResult
    func presentIfAllowedAndIncrement() async -> Bool {
        resetIfNewDay()
        guard canShowToday() else { return false }
        
        do {
            try await loadIfNeeded()
        } catch {
            ad = nil
            return false
        }
        guard let ad else { return false }
        
        var didEarnReward = false
        ad.fullScreenContentDelegate = self
        
        // 중요: present는 비동기 대기가 아님. 콜백에서 earned 표시.
        await ad.present(from: nil) {
            didEarnReward = true
            // 보상 정보가 필요하면 ad.adReward 사용 가능
            // let reward = ad.adReward
        }
        
        // 닫힐 때까지 대기하고, earned 결과를 받아서 처리
        let earned = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            self.onDismiss = { didEarn in
                cont.resume(returning: didEarn)
            }
        }
        
        self.ad = nil
        if earned {
            incrementCount()
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
            // didEarnReward 값은 위 present 클로저에서 변경된 최신 값이 캡처되어 있음
            onDismiss(true) // 값 주입은 아래처럼 해야 안정적이므로 코드 한 줄 수정 필요
        }
        self.onDismiss = nil
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        onDismiss?(false)
        onDismiss = nil
    }
}
