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
            Image("IMG_3245 2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(exhibition.title ?? "")
                    .font(.objectivityLargeTitle)
                    .padding(.bottom, 10)
                
                if let date = exhibition.date {
                    InfoDetailView(icon: "calendar", text: date.formatted(.iso8601.year().month().day()))
                }
                InfoDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "n/a")
                InfoDetailView(icon: "clock", text: "10:00 - 18:00")
                InfoDetailView(icon: "eye.slash.circle", text: "Mo., Fr.")
                InfoDetailView(icon: "person.crop.square", text: exhibition.artist ?? "unknown")
                
                Image(systemName: "doc.richtext")
                
                Text(exhibition.description ?? "none of description")
                    .multilineTextAlignment(.leading)
                    .font(.objectivityFootnote)
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("Awesome") // title과 같게
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



struct InfoDetailView: View {
    var icon: String
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            Divider()
        }
    }
}
