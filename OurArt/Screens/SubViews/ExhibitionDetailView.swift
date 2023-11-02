//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            Image("IMG_3245 2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, alignment: .center)
                .padding(.vertical, 30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Main Title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                InfoDetailView(icon: "calendar", text: "02.10.2023 - 11.10.2023")
                InfoDetailView(icon: "mappin.and.ellipse", text: "Heinrich Heine Allee 21")
                InfoDetailView(icon: "clock", text: "10:00 - 18:00")
                InfoDetailView(icon: "eye.slash.circle", text: "Mo., Fr.")
                InfoDetailView(icon: "person.crop.square", text: "Kero Park")
                
                Image(systemName: "doc.richtext")
                
                Text("I would like to show you all what is the most valuable things in my life. blah blah blah blah")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("Main Title")
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
        ExhibitionDetailView()
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
