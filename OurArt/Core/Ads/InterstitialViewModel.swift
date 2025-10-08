//
//  AdmobTestView.swift
//  OurArt
//
//  Created by Jongmo You on 06.10.25.
//

import SwiftUI
import GoogleMobileAds

class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitialAd: InterstitialAd?
    private var continuation: CheckedContinuation<Void, Never>?

    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: "ca-app-pub-3940256099942544/4411468910",
                request: Request()
            )
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            interstitialAd = nil
            print("전면광고 로드 실패: \(error.localizedDescription)")
        }
    }
    
    func presentAndWait() async {
        // 로드(성공/실패 무관)
        await loadAd()
        
        // 준비 안되면 바로 리턴(=광고 없이 진행)
        guard let interstitialAd else { return }
        
        await interstitialAd.present(from: nil)
        
        // 닫히거나 실패 콜백이 올 때까지 대기
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            self.continuation = cont
        }
    }
    
//    func showAd() {
//        guard let interstitialAd = interstitialAd else {
//            print("광고 준비 안됨")
//            return
//        }
//        interstitialAd.present(from: nil)
//    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        continuation?.resume()
        continuation = nil
        interstitialAd = nil
    }
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        continuation?.resume()
        continuation = nil
        interstitialAd = nil
    }
}
