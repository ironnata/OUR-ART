//
//  AboutDotView.swift
//  OurArt
//
//  Created by Jongmo You on 23.06.25.
//

import SwiftUI

struct AboutDotView: View {
    @Binding var version: String
    
    @State private var showCopyMessage = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer()
                
                logoImageAuth()
                
                Spacer()
                // 간단한 앱 소개 문구 ::::: Made for curious minds and creative souls who believe art belongs to everyone. 이 문구 넣자
                VStack {
                    HStack {
                        Text("🫶")
                        Text("Made for curious minds and makers who believe art belongs to everyone")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redacted)
                .clipShape(.rect(cornerRadius: 8))
                
                
                // 개발자 정보 ::::: 이름, 지역, 이메일 주소 정도?
                // Developed & designed by Jongmo
                // Seoul ↔ Düsseldorf
                // ironnata@gmail.com
                VStack(alignment: .leading, spacing: 12) {
                    AboutDotRowView(title: "Developed by", subtitle: "Jongmo")
                    Divider()
                    AboutDotRowView(title: "Designed by", subtitle: "Jongmo")
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
                    AboutDotRowView(title: "Version", subtitle: version)
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
                    .font(.objectivityTitle2)
            }
        }
    }
}

#Preview {
    AboutDotView(version: .constant("1.0.0"))
}

struct AboutDotRowView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondAccent)
            
            Spacer()
            
            Text(subtitle)
        }
    }
}
