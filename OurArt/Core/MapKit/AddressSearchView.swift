//
//  AddressSearchView.swift
//  OurArt
//
//  Created by Jongmo You on 07.10.24.
//

import SwiftUI
import MapKit

struct AddressSearchView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = AddressSearchViewModel(completer: .init())
    
    @State private var selectedLatitude: Double?
    @State private var selectedLongitude: Double?
    @State private var region: MKCoordinateRegion?
    @State private var annotations: [MKPointAnnotation] = []
    @State private var showList: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var selectedAddress: String
    @Binding var selectedCity: String
    @Binding var isPresented: Bool
    
    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let result = try? await viewModel.search(for: "\(completion.title) \(completion.subtitle)").first {
                selectedLatitude = result.coordinate.latitude
                selectedLongitude = result.coordinate.longitude
                
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                region = MKCoordinateRegion(center: result.coordinate, span: span)
                
                let coordinate = result.coordinate
                try await viewModel.updateAddress(for: coordinate)
            }
        }
    }
    
    private func updateAddress() {
        guard let latitude = selectedLatitude, let longitude = selectedLongitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        Task { @MainActor in
            do {
                try await viewModel.updateAddress(for: coordinate)
            } catch {
                print("Error updating address: \(error)")
            }
        }
    }

    
    var body: some View {
        ZStack {
            MapReader { proxy in
                MapView(selectedLatitude: $selectedLatitude, selectedLongitude: $selectedLongitude, region: $region, annotations: [])
                    .ignoresSafeArea()
                    .onChange(of: selectedLatitude) { _, _ in updateAddress() }
                    .onChange(of: selectedLongitude) { _, _ in updateAddress() }
            }
            
            if !isTextFieldFocused && !showList {
                VStack {
                    Spacer()
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundColor(.accent)
                    Spacer()
                }
            }
                
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                    }
                    
                    ZStack {
                        Color.background0
                        TextField("Search for an address...", text: $viewModel.queryFragment)
                            .autocorrectionDisabled()
                            .modifier(TextFieldModifier())
                            .showClearButton($viewModel.queryFragment)
                            .focused($isTextFieldFocused)
                            .onSubmit {
//                                performSearch()
                                Task {
                                    try await viewModel.search(for: viewModel.queryFragment)
                                }
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .onChange(of: viewModel.queryFragment) { _, newValue in
                                showList = !newValue.isEmpty
                            }
                    }
                    .frame(height: 48)
                    .clipShape(.rect(cornerRadius: 7))
                }
                .padding()
                .background(.clear)
                
                if showList {
                    List {
                        ForEach(viewModel.completions) { completion in
                            Button(action: {
                                didTapOnCompletion(completion)
                                showList = false
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(completion.title)
                                    Text(completion.subtitle)
                                        .foregroundStyle(Color.secondAccent)
                                }
                            }
                            .listRowBackground(Color.background0.opacity(0.6))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()
                
                if !isTextFieldFocused && !showList {
                    VStack(spacing: 10) {
                        Text(viewModel.selectedTitle)
                        Text(viewModel.selectedAddress)
                            .padding(.bottom, 20)
                        
                        Button("Select this address") {
                            selectedAddress = viewModel.selectedAddress
                            selectedCity = viewModel.selectedCity // 또는 적절한 도시 정보
                            isPresented = false
                        }
                        .modifier(CommonButtonModifier())
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(7)
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    AddressSearchView(selectedAddress: .constant(""), selectedCity: .constant(""), isPresented: .constant(true))
}
