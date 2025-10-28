//
//  AboutDotView.swift
//  OurArt
//
//  Created by Jongmo You on 23.06.25.
//

import SwiftUI

struct AboutDotView: View {
    @Binding var appVersion: String
    
    @State private var showCopyMessage = false
    @State private var animationAmount = 0.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer()
                
                logoImageAuth()
                    .onTapGesture {
                        withAnimation {
                            self.animationAmount += 360
                            Haptic.impact(style: .rigid)
                        }
                    }
                    .rotation3DEffect(
                        .degrees(animationAmount),
                        axis: (x: 0.0, y: 1.0, z: 0.0))
                
                Spacer()
                // 간단한 앱 소개 문구 ::::: Made for curious minds and creative souls who believe art belongs to everyone. 이 문구 넣자
                VStack {
                    HStack {
                        Text("🫶")
                            .font(.title3)
                        Text("Made for curious minds and makers who believe art belongs to everyone — and whose interest and support make Dot matter")
                            .lineSpacing(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.accent2)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 12) {
                    AboutDotRowView(title: "Developed by", subtitle: "Jongmo")
                    Divider()
                    AboutDotRowView(title: "Location", subtitle: "Düsseldorf ↔ Seoul")
                    Divider()
                    AboutDotRowView(title: "Contact", subtitle: "dotbymo@gmail.com")
                        .onLongPressGesture {
                            UIPasteboard.general.string = "dotbymo@gmail.com"
                            Haptic.notification()
                            withAnimation(.spring(response: 0.3)) {
                                showCopyMessage = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.spring(response: 0.3)) {
                                    showCopyMessage = false
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))

                // Version 정보
                VStack(alignment: .leading) {
                    AboutDotRowView(title: "Version", subtitle: appVersion)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))
                
                // Illustration Credits
                VStack(alignment: .leading) {
                    AboutDotRowView(title: "Illustrations by", subtitle: "getillustrations", url: URL(string: "https://getillustrations.com/"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))
                
                // Copyright © 2025 Jongmo. All rights reserved.
                // Thanks to
                VStack(alignment: .leading, spacing: 12) {
                    Text("Assembled with coffee, bugs and lots of love")
                    Text("Inspired by Teumssae")
                    
                    Divider()
                    
                    Text("Copyright © 2025 Jongmo. All rights reserved")
                }
                .font(.objectivityFootnote)
                .foregroundStyle(Color.accent2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))
            }
            .font(.objectivityCallout)
            
            if showCopyMessage {
                VStack {
                    BannerMessage(text: "Copied to clipboard")
                    Spacer()
                }
                .padding(.top, 200)
            }
        }
        .padding()
        .viewBackground()
        .toolbar {
            ToolbarBackButton()
            
            ToolbarItem(placement: .principal) {
                Text("About Dot")
                    .font(.objectivityTitle3)
            }
        }
    }
}

#Preview {
    AboutDotView(appVersion: .constant("1.0"))
}

struct AboutDotRowView: View {
    var title: String
    var subtitle: String
    var url: URL? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondAccent)
            
            Spacer()
            
            if let url = url {
                Link(subtitle, destination: url)
                    .foregroundColor(.blue)
                    .underline()
            } else {
                Text(subtitle)
            }
        }
    }
}
