//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let exhibition: Exhibition
    
    var body: some View {
        ScrollView {
            Image("IMG_3245 2") // 수정 요
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(exhibition.title ?? "n/a")
                    .font(.objectivityLargeTitle)
                    .padding(.bottom, 10)
                
                
                if let dateFrom = exhibition.dateFrom?.formatted(.iso8601.year().month().day()),
                    let dateTo = exhibition.dateTo?.formatted(.iso8601.year().month().day()) {
                    InfoDetailView(icon: "calendar", text: "\(dateFrom) - \(dateTo)")
                }
                
                InfoDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "n/a")
                
                if let openingTimeFrom = exhibition.openingTimeFrom?.formatted(date: .omitted, time: .shortened),
                    let openingTimeTo = exhibition.openingTimeTo?.formatted(date: .omitted, time: .shortened) {
                    InfoDetailView(icon: "clock", text: "\(openingTimeFrom) - \(openingTimeTo)")
                }
                
                InfoDetailView(icon: "eye.slash.circle", text: exhibition.closingDays ?? ["n/a"])
                
                InfoDetailView(icon: "person.crop.square", text: exhibition.artist ?? "n/a")
                
                Image(systemName: "doc.richtext")
                
                Text(exhibition.description ?? "n/a")
                    .multilineTextAlignment(.leading)
                    .font(.objectivityFootnote)
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("\(exhibition.title ?? "")")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
}




#Preview {
    NavigationStack {
        ExhibitionDetailView(exhibition: Exhibition(id: "1"))
    }
}



struct InfoDetailView<T: CustomStringConvertible>: View {
    var icon: String
    var text: T
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                if let arrayText = text as? [String] {
                    // 배열일 경우 문자열로 조인
                    Text(arrayText.joined(separator: ", "))
                } else {
                    // 아닐 경우 문자열 그대로 출력
                    Text(String(describing: text))
                }
            }
            Divider()
        }
    }
}
