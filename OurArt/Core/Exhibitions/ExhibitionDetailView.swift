//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI
import MapKit

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var myExhibitionVM = MyExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    @StateObject private var mapVM = MapViewModel()
    
    @State private var showDeleteAlert = false
    @State private var showEditView = false
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    @State private var isLoading = true
    
    var myExhibitionId: String?
    var exhibitionId: String // exhibition 객체 대신 ID만 받음
    var isMyExhibition: Bool = false
    
    private func loadData() {
        if isMyExhibition {
            if let myExhibitionId = myExhibitionId {
                myExhibitionVM.loadMyExhibition(myExhibitionId: myExhibitionId)
            }
        }
        
        // 모든 경우에 전시회 데이터 로드
        Task {
            do {
                try await exhibitionVM.loadCurrentExhibition(id: exhibitionId)
                isLoading = false
                
                // 주소가 있으면 지도 표시
                if let address = exhibitionVM.exhibition?.address {
                    mapVM.showAddress(for: address)
                }
            } catch {
                print("전시회 데이터 로드 실패: \(error)")
                isLoading = false
            }
        }
    }
    
    private func handleDelete() {
        if let myExhibitionId = myExhibitionId {
            myExhibitionVM.deleteMyExhibition(myExhibitionId: myExhibitionId)
            dismiss()
        }
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .navigationBarBackButtonHidden()
            } else if let exhibition = exhibitionVM.exhibition {
                ScrollView {
                    // TEST용
                    // Text(exhibitionId)
                    
                    AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 240, alignment: .center)
                            .clipShape(.rect(cornerRadius: 8))
                            .onTapGesture {
                                withAnimation {
                                    currentImage = image
                                    isZoomed.toggle()
                                }
                            }
                    } placeholder: {
                        Text("No Poster")
                            .frame(width: 240, height: 360, alignment: .center)
                            .font(.objectivityTitle2)
                    }
                    .padding(.vertical, 30)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exhibition.title ?? "n/a")
                            .font(.objectivityTitle)
                            .padding(.bottom, 20)
                        
                        InfoDetailView(icon: "person.crop.rectangle.fill", text: exhibition.artist ?? "No information")
                        
                        if let dateFrom = exhibition.dateFrom,
                           let dateTo = exhibition.dateTo {
                            let dateFormatter = DateFormatter.localizedDateFormatter()
                            let formattedDateFrom = dateFormatter.string(from: dateFrom)
                            let formattedDateTo = dateFormatter.string(from: dateTo)
                            
                            InfoDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)")
                        }
                        
                        if let openingTimeFrom = exhibition.openingTimeFrom,
                           let openingTimeTo = exhibition.openingTimeTo {
                            let dateFormatter = DateFormatter.timeOnlyFormatter()
                            
                            let formattedOpeningTimeFrom = dateFormatter.string(from: openingTimeFrom)
                            let formattedOpeningTimeTo = dateFormatter.string(from: openingTimeTo)
                            
                            InfoDetailView(icon: "clock", text: "\(formattedOpeningTimeFrom) - \(formattedOpeningTimeTo)")
                        }
                        
                        InfoDetailView(icon: "eye.slash.circle", text: exhibition.closingDays ?? ["No information"])
                        
                        InfoDetailView(icon: "mappin.and.ellipse.circle", text: exhibition.address ?? "No information")
                            .textSelection(.enabled)
                            .onChange(of: exhibition.address) { _, newAddress in
                                if let address = newAddress {
                                    mapVM.showAddress(for: address)
                                }
                            }
                        
                        if let coordinate = mapVM.coordinate {
                            let region = MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                            )
                            
                            Map(position: .constant(.region(region))) {
                                Annotation("", coordinate: coordinate, anchor: .bottom) {
                                    Image(systemName: "mappin.and.ellipse.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.accent)
                                        .symbolEffect(.pulse)
                                }
                            }
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .disabled(true)
                            
                            Divider()
                        }
                        
                        Text(exhibition.description ?? "")
                            .multilineTextAlignment(.leading)
                            .lineSpacing(7)
                            .font(.objectivityCallout)
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                        }
                    }
                    
                    if isMyExhibition {
                        ToolbarItem(placement: .topBarTrailing) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                                .onTapGesture {
                                    showEditView = true
                                }
                                .padding(.trailing, 10)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Image(systemName: "trash")
                                .imageScale(.large)
                                .onTapGesture {
                                    showDeleteAlert = true
                                }
                        }
                    }
                }
                .onAppear {
                    UINavigationController.swizzleIfNeeded()
                }
                .alert("", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        handleDelete()
                    }
                } message: {
                    Text("This exhibition will be permanently deleted. Do you wish to proceed?")
                }
                .sheet(isPresented: $showEditView, onDismiss: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let myExhibitionId {
                            myExhibitionVM.loadMyExhibition(myExhibitionId: myExhibitionId)
                        }
                        
                        // 편집 후 데이터 다시 로드
                        Task {
                            try await exhibitionVM.loadCurrentExhibition(id: exhibitionId)
                        }
                    }
                }) {
                    EditMyExhibitionView(showEditView: $showEditView, exhibitionId: exhibitionId)
                        .interactiveDismissDisabled(true)
                }
            } else {
                Text("전시회 정보를 불러올 수 없습니다.")
            }
        }
        .overlay {
            Group {
                if isZoomed, let image = currentImage {
                    FullScreenPosterView(isZoomed: $isZoomed, image: image)
                }
            }
        }
        .toolbar(isZoomed ? .hidden : .automatic, for: .navigationBar)
        .onAppear {
            loadData()
        }
        .viewBackground()
    }
}

// Preview 수정
#Preview {
    NavigationStack {
        ExhibitionDetailView(exhibitionId: "1", isMyExhibition: true)
    }
}

struct InfoDetailView<T: CustomStringConvertible>: View {
    var icon: String
    var text: T
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
                if let arrayText = text as? [String] {
                    // 배열일 경우 문자열로 조인
                    Text(arrayText.joined(separator: ", "))
                } else {
                    // 아닐 경우 문자열 그대로 출력
                    Text(String(describing: text))
                }
            }
            .font(.objectivityThinBody)
            
            Divider()
        }
    }
}

private extension UINavigationController {
    static var swizzleDidLoad: Bool = false
    
    static func swizzleIfNeeded() {
        guard !swizzleDidLoad else { return }
        
        swizzleDidLoad = true
        
        let originalSelector = #selector(viewDidLoad)
        let swizzledSelector = #selector(swizzledViewDidLoad)
        
        let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector)
        
        if let originalMethod = originalMethod,
           let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc func swizzledViewDidLoad() {
        swizzledViewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}

