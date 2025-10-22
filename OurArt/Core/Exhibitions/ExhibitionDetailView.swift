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
    @Environment(\.openURL) private var openURL
    
    @StateObject private var myExhibitionVM = MyExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    @StateObject private var mapVM = MapViewModel()
    
    @State private var showDeleteAlert = false
    @State private var showEditView = false
    @State private var showCopyMessage = false
    @State private var showMap = false
    @State private var mapHeight: CGFloat = 0
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    @State private var isLoading = true
    
    @State private var isExpanded = false
    @State private var truncated = false
    
    var myExhibitionId: String?
    var exhibitionId: String // exhibition 객체 대신 ID만 받음
    var isMyExhibition: Bool = false
    
    func animateMapAppearance() {
        withAnimation(.spring(response: 0.8, dampingFraction: 1.5)) {
            mapHeight = 140 // 원하는 높이
        }
    }
    
    private func loadData() {
        if isMyExhibition {
            if let myExhibitionId = myExhibitionId {
                myExhibitionVM.loadMyExhibition(myExhibitionId: myExhibitionId)
            }
        }
        
        Task {
            do {
                try await exhibitionVM.loadCurrentExhibition(id: exhibitionId)
                isLoading = false
                
                if let address = exhibitionVM.exhibition?.address {
                    mapVM.showAddress(for: address)
                }
            } catch {
                print("전시회 데이터 로드 실패: \(error)")
                isLoading = false
            }
        }
    }
    
    private func handleDelete() async throws {
        if let myExhibitionId = myExhibitionId {
            try await myExhibitionVM.deleteMyExhibition(myExhibitionId: myExhibitionId)
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
                        Text("No Poster") // 뭔가 플레이스홀더를 만들어볼까? 흠........ //
                            .frame(width: 240, height: 240, alignment: .center)
                            .font(.objectivityTitle3)
                    }
                    .padding(.bottom, 30)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exhibition.title ?? "")
                            .font(.objectivityTitle3)
                            .padding(.bottom, 15)
                            .padding(.horizontal, 10)
                            .lineSpacing(8)
                        
                        VStack(spacing: 10) {
                            InfoDetailView(icon: "person.crop.rectangle.fill", text: exhibition.artist ?? "Unknown")
                            
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
                            
                            InfoDetailView(icon: "xmark.circle", text: exhibition.closingDays ?? ["Always open"])
                            
                            InfoDetailView(icon: "location.circle", text: exhibition.address ?? "Unknown")
                                .lineSpacing(9)
                                .onLongPressGesture {
                                    UIPasteboard.general.string = exhibition.address ?? ""
                                    Haptic.notification()
                                    withAnimation(.spring(response: 0.3)) {
                                        showCopyMessage = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showCopyMessage = false
                                        }
                                    }
                                }
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
                                
                                if showMap {
                                    Map(position: .constant(.region(region))) {
                                        Annotation("", coordinate: coordinate, anchor: .bottom) {
                                            Image(systemName: "smallcircle.filled.circle")
                                                .font(.title3)
                                                .foregroundStyle(Color.accent)
                                                .symbolEffect(.pulse)
                                        }
                                    }
                                    .frame(height: mapHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .disabled(true)
                                    .onTapGesture {
                                        mapVM.openMapAtCoordinate(coordinate)
                                    }
                                    .onAppear {
                                        animateMapAppearance()
                                    }
                                    
                                    Divider()
                                } else {
                                    InfoDetailView(icon: "map.circle", text: "View Map")
                                        .onTapGesture {
                                            showMap = true
                                        }
                                }
                            } else {
                                if let urlString = exhibition.onlineLink, let url = URL(string: urlString) {
                                    Link(destination: url) {
                                            InfoDetailView(icon: "link.circle", text: "Visit Site")
                                        }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redacted)
                        .clipShape(.rect(cornerRadius: 8))
                        
                        SimpleExpandableTextView(text: exhibition.description ?? "")
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarBackButton()
                    
                    if isMyExhibition {
                        CompatibleToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button(action: {
                                    showEditView = true
                                }) {
                                    Label("Edit", systemImage: "square.and.pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    showDeleteAlert = true
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                .onAppear {
                    UINavigationController.swizzleIfNeeded()
                }
                .alert("", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        Task {
                            try await handleDelete()
                        }
                    }
                } message: {
                    Text("Deleting this dot is permanent. Wanna go ahead?")
                }
                .sheet(isPresented: $showEditView, onDismiss: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let myExhibitionId {
                            myExhibitionVM.loadMyExhibition(myExhibitionId: myExhibitionId)
                        }

                        Task {
                            try await exhibitionVM.loadCurrentExhibition(id: exhibitionId)
                        }
                    }
                }) {
                    EditMyExhibitionView(showEditView: $showEditView, exhibitionId: exhibitionId)
                        .interactiveDismissDisabled(true)
                }
            } else {
                Text("Unable to load exhibition information")
            }
            
            if showCopyMessage {
                VStack {
                    BannerMessage(text: "Copied to clipboard")
                    Spacer()
                }
                .padding(.top, 200)
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
            .font(.objectivityCallout)
            
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

