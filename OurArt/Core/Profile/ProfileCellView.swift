//
//  ProfileCellView.swift
//  OurArt
//
//  Created by Jongmo You on 15.11.23.
//

import SwiftUI

struct ProfileCellView: View {
    @StateObject var viewModel = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        HStack {
            if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                .padding(.trailing, 30)
            }
            
            Text("\(viewModel.user?.nickname ?? "" )")
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline) {
                Text("\((viewModel.user?.preferences ?? []).joined(separator: ", "))")
                    .font(.footnote)
                    .padding(.trailing, 20)
                
                NavigationLink {
                    // ProfileEditView
                    EmptyView()
                } label: { }.frame(width: 0, height: 0)
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    ProfileCellView(showSignInView: .constant(true))
}
