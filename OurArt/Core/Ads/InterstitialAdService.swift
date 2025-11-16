//
//  AdmobTestView.swift
//  OurArt
//
//  Created by Jongmo You on 06.10.25.
//

import SwiftUI
import GoogleMobileAds

final class InterstitialAdService: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = InterstitialAdService()
    private override init() {}
    
    private var ad: InterstitialAd?
    private let adUnitId = "ca-app-pub-3940256099942544/4411468910"
    private var continuation: CheckedContinuation<Bool, Never>?
    
    func preloadAd() async {
        do {
            ad = try await InterstitialAd.load(with: adUnitId, request: Request())
            ad?.fullScreenContentDelegate = self
            print("전면광고 미리 로드 완료")
        } catch {
            ad = nil
            print("전면광고 로드 실패: \(error)")
        }
    }
    
    func presentAd() async -> Bool {
        guard let ad else { return false }
        
        await ad.present(from: nil)
        
        let success = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            self.continuation = cont
        }
        
        self.ad = nil
        return success
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        continuation?.resume(returning: true)
        continuation = nil
        self.ad = nil
    }
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        continuation?.resume(returning: false)
        continuation = nil
        self.ad = nil
    }
}


class InterstitialViewModel: ObservableObject {
    func preloadAd() async {
        await InterstitialAdService.shared.preloadAd()
    }
    
    func presentAd() async {
        let success = await InterstitialAdService.shared.presentAd()
    }
    
    
    func presentAndWait() async {
        await InterstitialAdService.shared.preloadAd()
        let success = await InterstitialAdService.shared.presentAd()
        // 필요시 UI 상태 업데이트
    }
}
