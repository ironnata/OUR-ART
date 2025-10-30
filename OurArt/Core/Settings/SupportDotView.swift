//
//  SupportDotView.swift
//  OurArt
//
//  Created by Jongmo You on 08.10.25.
//

import SwiftUI

struct SupportDotView: View {
    @StateObject private var adViewModel = RewardedInterstitialViewModel()
    
    @State private var animationAmount = 0.0
    @State private var showLogo = true
    @State private var isBouncing = false
    
    @State private var adCount: Int = 0
    @State private var thanksMessages = ["Feel free to share your kindness with us", "DOT feels your kindness", "Your support shines brighter", "DOT’s heart is glowing!", "Your kindness is deeply felt", "Your kindness today was more than enough — thank you"]
    
    @State private var animatedHeartIndex: Int? = nil
    @State private var heartAnimationValues = HeartAnimationValues()
    @State private var animationTrigger = 0
    @State private var isHeartsAnimating = false
    
    private func triggerHeartAnimation(for heartIndex: Int) {
        animatedHeartIndex = heartIndex
        animationTrigger += 1
        
        // 애니메이션 완료 후 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animatedHeartIndex = nil
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                VStack(spacing: 10) {
                    let safeHeight = proxy.size.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom
                    
                    VStack {
                        
                        Spacer()
                        
//                        if adCount >= 5 {
//                            if #available(iOS 18.0, *) {
//                                Image(systemName: "hands.and.sparkles")
//                                    .font(.system(size: 70))
//                                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous))
//                                    .onTapGesture {
//                                        withAnimation {
//                                            self.animationAmount += 360
//                                            Haptic.impact(style: .rigid)
//                                        }
//                                    }
//                                    .rotation3DEffect(
//                                        .degrees(animationAmount),
//                                        axis: (x: 0.0, y: 1.0, z: 0.0))
//                            } else {
//                                Image(systemName: "hands.and.sparkles.fill")
//                                    .font(.system(size: 70))
//                                    .onTapGesture {
//                                        withAnimation {
//                                            self.animationAmount += 360
//                                            Haptic.impact(style: .rigid)
//                                        }
//                                    }
//                                    .rotation3DEffect(
//                                        .degrees(animationAmount),
//                                        axis: (x: 0.0, y: 1.0, z: 0.0))
//                            }
//                        } else {
//                            logoImageAuth()
//                                .onTapGesture {
//                                    withAnimation {
//                                        self.animationAmount += 360
//                                        Haptic.impact(style: .rigid)
//                                    }
//                                }
//                                .rotation3DEffect(
//                                    .degrees(animationAmount),
//                                    axis: (x: 0.0, y: 1.0, z: 0.0))
//                        }
                        
                        ZStack {
                            if adCount >= 5 {
                                Image("Relationships _ love, heart, hands, abstract, Vector illustration")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 114)
                                    .foregroundStyle(Color.accent)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 1).repeatForever()) {
                                            isBouncing = true
                                        }
                                    }
                                    .scaleEffect(isBouncing ? 1.2 : 1.0)
                                    .onTapGesture {
                                        withAnimation {
                                            self.animationAmount += 360
                                            Haptic.impact(style: .rigid)
                                        }
                                    }
                                    .rotation3DEffect(
                                        .degrees(animationAmount),
                                        axis: (x: 0.0, y: 1.0, z: 0.0))
                            }
                            
                            if showLogo {
                                logoImageAuth()
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            showLogo = false
                                            Haptic.impact(style: .soft)
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                showLogo = true
                                            }
                                        }
                                    }
                                    .opacity(adCount >= 5 ? 0.0 : 1.0)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("🫰")
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Thank you for supporting Dot")
                                Text("Every little tap means a lot")
                            }
                            .font(.objectivityCallout)
                            .foregroundStyle(Color.accent2)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redacted)
                        .clipShape(.rect(cornerRadius: 8))
                    }
                    .frame(height: safeHeight * 0.5)
                    
                    VStack {
                        Spacer()
                        
                        Button {
                            Task {
                                let shown = await adViewModel.presentIfAllowedAndIncrement()
                                // 광고 성공(보상 획득) 시 카운트 갱신
                                if shown {
                                    let newCount = adViewModel.currentCount()
                                    
                                    // 새로운 하트가 생겼을 때 애니메이션 트리거
                                    if newCount > adCount {
                                        triggerHeartAnimation(for: newCount - 1)
                                    }
                                    
                                    adCount = newCount
                                }
                            }
                            
                        } label: {
                            if adCount >= 5 {
                                Image("Relationships _ heart shapes, balloons, floating, celebrating love")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45)
                                    .foregroundStyle(Color.redacted)
                                    .frame(width: 150, height: 90)
                                    .background(Color.accent)
                                    .clipShape(.rect(cornerRadius: 15))
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 45))
                                    .foregroundStyle(Color.redacted)
                                    .frame(width: 150, height: 90)
                                    .background(Color.accent)
                                    .clipShape(.rect(cornerRadius: 15))
                                    .shadow(radius: 10)
                            }
                        }
                        .disabled(adCount >= 5)
                        
                        Text(adCount >= 5 ? "" : "Watch Ad to support Dot")
                            .font(.objectivityCallout)
                            .foregroundStyle(Color.accent2)
                            .padding(.bottom, 20)
                        
                        HStack(spacing: 8) {
                            ForEach(0..<adCount, id: \.self) { index in
                                let isAnimating = animatedHeartIndex == index
                                
                                Image(systemName: "heart.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 25)
                                    .symbolRenderingMode(.multicolor)
                                    .onTapGesture {
                                        if adCount >= 5 && !isHeartsAnimating {
                                            isHeartsAnimating = true
                                            for i in 0..<5 {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                                                    triggerHeartAnimation(for: i)
                                                    
                                                    if i == 4 {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                            isHeartsAnimating = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .keyframeAnimator(
                                        initialValue: HeartAnimationValues(),
                                        trigger: isAnimating ? animationTrigger : -1  // ✅ isAnimating이 false면 -1로 설정
                                    ) { content, value in
                                        content
                                            .rotationEffect(value.angle)
                                            .scaleEffect(value.scale)
                                            .scaleEffect(y: value.verticalStretch)
                                            .offset(y: value.verticalTranslation)
                                    } keyframes: { _ in
                                        KeyframeTrack(\.angle) {
                                            CubicKeyframe(.zero, duration: 0.58)
                                            CubicKeyframe(.degrees(16), duration: 0.125)
                                            CubicKeyframe(.degrees(-16), duration: 0.125)
                                            CubicKeyframe(.degrees(16), duration: 0.125)
                                            CubicKeyframe(.zero, duration: 0.125)
                                        }
                                        
                                        KeyframeTrack(\.verticalStretch) {
                                            CubicKeyframe(1.0, duration: 0.1)
                                            CubicKeyframe(0.6, duration: 0.15)
                                            CubicKeyframe(1.5, duration: 0.1)
                                            CubicKeyframe(1.05, duration: 0.15)
                                            CubicKeyframe(1.0, duration: 0.88)
                                            CubicKeyframe(0.8, duration: 0.1)
                                            CubicKeyframe(1.04, duration: 0.4)
                                            CubicKeyframe(1.0, duration: 0.22)
                                        }
                                        
                                        KeyframeTrack(\.scale) {
                                            LinearKeyframe(1.0, duration: 0.36)
                                            SpringKeyframe(1.5, duration: 0.8, spring: .bouncy)
                                            SpringKeyframe(1.0, spring: .bouncy)
                                        }
                                        
                                        KeyframeTrack(\.verticalTranslation) {
                                            LinearKeyframe(0.0, duration: 0.1)
                                            SpringKeyframe(5.0, duration: 0.15, spring: .bouncy)
                                            SpringKeyframe(-20.0, duration: 1.0, spring: .bouncy)
                                            SpringKeyframe(0.0, spring: .bouncy)
                                        }
                                    }
                            }
                        }
                        .padding()
                        
                        HStack(spacing: 10) {
                            Text("\(thanksMessages[adCount])")
                                .lineSpacing(10)
                        }
                        
                        Spacer()
                    }
                    .frame(height: safeHeight * 0.5)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.redacted)
                    .clipShape(.rect(cornerRadius: 8))
                }
                .padding()
            }
        }
        .viewBackground()
        .toolbar {
            ToolbarBackButton()
            
            ToolbarItem(placement: .principal) {
                Text("Support Dot")
                    .font(.objectivityTitle3)
            }
        }
        .onAppear {
            adCount = adViewModel.currentCount()
            
            Task {
                await adViewModel.preloadAd()
            }
        }
    }
}

#Preview {
    SupportDotView()
}
