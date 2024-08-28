//
//  ProfileCellView.swift
//  OurArt
//
//  Created by Jongmo You on 15.11.23.
//

import SwiftUI

struct ProfileCellView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    let placeholderImage = Image(systemName: "person.circle.fill")
    
    var body: some View {
        ZStack {
            HStack {
                if let user = viewModel.user {
                    
                    if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .modifier(SmallProfileImageModifer())
                        } placeholder: {
                            placeholderImage
                                .resizable()
                                .modifier(SmallProfileImageModifer())
                                .foregroundStyle(Color.secondAccent)
                        }
                        .padding(.trailing, 30)
                    } else {
                        placeholderImage
                            .resizable()
                            .modifier(SmallProfileImageModifer())
                            .foregroundStyle(Color.secondAccent)
                            .padding(.trailing, 30)
                    }
                    
                    
                    Text("\(user.nickname ?? "" )")
                    
                    Spacer()
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text("\(user.preferences?.isEmpty == false ? user.preferences!.joined(separator: ", ") : "Audience")")
                            .font(.footnote)
                            .padding(.trailing, 20)
                        
                        NavigationLink {
                            ProfileEditView(showSignInView: $showSignInView)
                                .navigationBarBackButtonHidden(true)
                        } label: { }.frame(width: 0, height: 0)
                    }
                    
                }
            }
            .task {
                try? await viewModel.loadCurrentUser()
            }
        }
        .viewBackground()
    }
}

#Preview {
    ProfileCellView(showSignInView: .constant(true))
}
