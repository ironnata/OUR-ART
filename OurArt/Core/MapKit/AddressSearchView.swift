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
    @State private var mapRotation: Double = 0
    @State private var showList = false
    @State private var showHelpMessage = false
    
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
                MapView(selectedLatitude: $selectedLatitude, 
                       selectedLongitude: $selectedLongitude, 
                       region: $region, 
                       mapRotation: $mapRotation,
                       annotations: [])
                    .ignoresSafeArea()
                    .onChange(of: selectedLatitude) { _, _ in updateAddress() }
                    .onChange(of: selectedLongitude) { _, _ in updateAddress() }
            }
            
            if !isTextFieldFocused && !showList {
                VStack {
                    Spacer()
                    Image(systemName: "mappin.and.ellipse.circle.fill")
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
                        TextField("Search for an address", text: $viewModel.queryFragment)
                            .autocorrectionDisabled()
                            .modifier(TextFieldModifier())
                            .showClearButton($viewModel.queryFragment)
                            .focused($isTextFieldFocused)
                            .onSubmit {
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
                .background(Color.background0)
                .ignoresSafeArea(.all, edges: .top)
                
                if !showList {
                    HStack {
                        Spacer()
                        
                        if showHelpMessage {
                            BannerMessage(text: "Can’t find the right spot? Try moving the map and place your dot in the exact location you want")
                                .offset(x: 20)
                        }
                        
                        Button {
                            withAnimation {
                                showHelpMessage.toggle()
                            }
                        } label: {
                            Image(systemName: "questionmark")
                                .font(.title2)
                                .foregroundStyle(Color.accent)
                                .padding(10)
                                .background(Color.background0)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                }
                
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
                    .cornerRadius(7)
                }
                
                Spacer()
                
                if !isTextFieldFocused && !showList {
                    VStack(spacing: 10) {
                        Text(viewModel.selectedTitle)
                        Text(viewModel.selectedAddress)
                            .padding(.bottom, 20)
                        
                        Button("Select this address") {
                            selectedAddress = viewModel.selectedAddress
                            selectedCity = viewModel.selectedCity
                            isPresented = false
                        }
                        .modifier(CommonButtonModifier())
                    }
                    .padding()
                    .padding(.bottom, 20)
                    .background(Color.background0)
                    .cornerRadius(7)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .keyboardAware(minDistance: 32)
            
            // 나침반 버튼 위치 조정
            VStack {
                Spacer()
                    .frame(height: 150)
                HStack {
                    Spacer()
                    if abs(mapRotation) > 0.1 { // 회전 각도가 0.1도 이상일 때만 표시
                        Button {
                            if let latitude = selectedLatitude, let longitude = selectedLongitude {
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                region = MKCoordinateRegion(center: coordinate, span: span)
                            }
                        } label: {
                            Image(systemName: "location.north.fill")
                                .font(.headline)
                                .foregroundStyle(Color.accent)
                                .padding(10)
                                .background(Color.background0)
                                .clipShape(Circle())
                                .rotationEffect(.degrees(-mapRotation)) // 나침반이 항상 북쪽을 가리키도록 회전
                                .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: mapRotation) // 부드러운 회전 애니메이션 추가
                        }
                        .padding(.trailing)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AddressSearchView(selectedAddress: .constant(""), selectedCity: .constant(""), isPresented: .constant(true))
}
