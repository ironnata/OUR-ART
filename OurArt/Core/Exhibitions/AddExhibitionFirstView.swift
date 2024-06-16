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
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                        TextField("Title...", text: $title)
                            .modifier(TextFieldModifier())
                    } // Title
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)
                    
                    Button {
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
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Text("New Exhibition")
                            .font(.objectivityTitle)
                    }
                }
            }
            .viewBackground()
        }
    }
}

#Preview {
    AddExhibitionFirstView(showAddingView: .constant(false))
}
