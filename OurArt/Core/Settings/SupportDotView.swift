//
//  SupportDotView.swift
//  OurArt
//
//  Created by Jongmo You on 08.10.25.
//

import SwiftUI

struct SupportDotView: View {
    @State private var adCount: Int = 0
    @State private var thanksMessages = ["Feel free to share your kindness with us", "DOT feels your kindness", "Your support shines brighter", "DOT’s heart is glowing!", "Your kindness is deeply felt", "Your kindness today was more than enough — thank you"]
    let hearts = ["🤍", "💛", "🧡", "❤️", "💖"]
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                VStack(spacing: 10) {
                    let safeHeight = proxy.size.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom
                    
                    VStack {
                        
                        Spacer()
                        
                        if adCount >= 5 {
                            if #available(iOS 18.0, *) {
                                Image(systemName: "hands.and.sparkles")
                                    .font(.system(size: 70))
                                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous))
                            } else {
                                Image(systemName: "hands.and.sparkles.fill")
                                    .font(.system(size: 70))
                            }
                        } else {
                            logoImageAuth()
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
                            // if adCount = 5, 버튼 비활성화 or 큰 움직이는 박수 이모티콘으로 대체
                            
                            Task {
                                let shown = await RewardedInterstitialService.shared.presentIfAllowedAndIncrement()
                                // 광고 성공(보상 획득) 시 카운트 갱신
                                if shown {
                                    adCount = RewardedInterstitialService.shared.currentCount()
                                }
                            }
                            
                        } label: {
                            if adCount >= 5 {
                                Text("🙇‍♂️")
                                    .font(.system(size: 45))
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
                            .foregroundStyle(Color.secondAccent)
                            .padding(.bottom, 20)
                        
                        HStack(spacing: 3) {
                            ForEach(0..<min(adCount, hearts.count), id: \.self) { heart in
                                Text(hearts[heart])
                                    .font(.title)
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
            adCount = RewardedInterstitialService.shared.currentCount()
        }
    }
}

#Preview {
    SupportDotView()
}
