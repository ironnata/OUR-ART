//
//  AddExhibitionFirstView.swift
//  OurArt
//
//  Created by Jongmo You on 18.12.23.
//

import SwiftUI

struct AddExhibitionFirstView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @Binding var showAddingView: Bool
    @Binding var isUploaded: Bool

    @State private var showSecondView = false
    @State private var title: String = ""
    @State private var currentId: String = UUID().uuidString
    
    @FocusState private var isTitleFocused: Bool
    
    let imageNames = [
        "Family and Children _ mother, child, embrace, bond, nurturing",
        "Nature and Ecology _ night, moon, stars, landscape",
        "Creative Design _ woman, portrait, artistic, fashion",
        "Creative Design _ woman, girl, jewelry, headpiece, minimalist",
        "Home Improvement _ house, repair, handyman, construction, DIY, Vector illustration",
        "Lifestyle and Leisure _ sleeping, rest, relaxation, man, silhouette, Vector illustration",
        "Food and Cuisine _ chef, cooking, restaurant, culinary, kitchen",
        "Family and Children _ silhouette, family, journey, path, line art",
        "Creative Design _ abstract, surreal, character, face, whimsical",
        "Nature and Ecology _ wave, ocean, nature, minimal, Vector illustration"
    ]
    
    @State private var randomImageName: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
//                    Spacer()
                    if let imageName = randomImageName {
                        Image(imageName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.accent)
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                            .padding(.bottom, 10)
                    }
                    
//                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Title", text: $title)
                            .modifier(TextFieldModifier())
                            .focused($isTitleFocused)
                            .showClearButton($title)
                        Text("If the title is empty, it will be set to 'No title'")
                            .font(.objectivityFootnote)
                            .foregroundStyle(.secondAccent)
                    } // Title
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)
                    
                    Button {
                        if title.isEmpty {
                            title = "No title"
                        }
                        
                        let newExhibition = Exhibition(
                            id: currentId,
                            dateCreated: Date(),
                            title: title,
                            uploadStatus: "draft"
                        )
                        
                        Task {
                            try await viewModel.createExhibition(exhibition: newExhibition)
                        }
                        
                        showSecondView = true
                        
                    } label: {
                        Text("Next".uppercased())
                    }
                    .modifier(CommonButtonModifier())
                    .navigationDestination(isPresented: $showSecondView) {
                        AddExhibitionSecondView(showAddingView: $showAddingView, title: $title, currentId: $currentId, isUploaded: $isUploaded)
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .padding()
                .toolbar {
                    CompatibleToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()   
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                        }
                    }
                    
                    CompatibleToolbarItem(placement: .topBarLeading) {
                        Text("New Exhibition")
                            .font(.objectivityTitle2)
                            .frame(width: 200, alignment: .leading)
                    }
                }
            }
            .viewBackground()
            .onAppear {
                randomImageName = imageNames.randomElement()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isTitleFocused = true
                }
            }
        }
        .onTapGesture {
            if isTitleFocused {
                isTitleFocused = false
            }
        }
    }
}

#Preview {
    AddExhibitionFirstView(showAddingView: .constant(false), isUploaded: .constant(false))
}
