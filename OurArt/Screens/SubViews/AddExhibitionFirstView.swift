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

    
    var body: some View {
        NavigationStack {
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
                        id: UUID().uuidString,
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
                    AddExhibitionSecondView(showAddingView: $showAddingView)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .navigationTitle("New Exhibiton")
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
    }
}

#Preview {
    AddExhibitionFirstView(showAddingView: .constant(false))
}
