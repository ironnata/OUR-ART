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

    @State private var showSecondView = false
    @State private var title: String = ""
    @State private var currentId: String = UUID().uuidString

    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    
                    Image("DOT_AddExhibitionFirst")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        .padding(.bottom, 10)
                        .opacity(0.7)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Title", text: $title)
                            .modifier(TextFieldModifier())
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
                            title: title
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
                        AddExhibitionSecondView(showAddingView: $showAddingView, title: $title, currentId: $currentId)
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()   
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Text("New Exhibition")
                            .font(.objectivityTitle)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .keyboardAware(minDistance: 32)
            }
            .viewBackground()
        }
    }
}

#Preview {
    AddExhibitionFirstView(showAddingView: .constant(false))
}
