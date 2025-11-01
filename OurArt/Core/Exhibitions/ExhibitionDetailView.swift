//
//  ExhibitionDetailView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI
import MapKit
import UIKit

struct ExhibitionDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL
    
    @StateObject private var myExhibitionVM = MyExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    @StateObject private var mapVM = MapViewModel()
    
    @Namespace private var fullPosterNS
    
    let copyrightNotice = "※ Exhibition details provided by Dot. All rights reserved by the creators"
    let placeholderImage = Image("Cultural and Social Issues _ peace, protest, hand, political, activism")
    
    @State private var showDeleteAlert = false
    @State private var showEditView = false
    @State private var showCopyMessage = false
    @State private var showShareAlert = false
    
    @State private var cameraTrigger = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showMap = false
    @State private var mapHeight: CGFloat = 0
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    @State private var isLoading = true
    
    @State private var showLinkAlert = false
    @State private var pendingURL: URL?
    
    @State private var isRefreshing = false
    
    var exhibitionId: String
    
    var myExhibitionId: String?
    var isMyExhibition: Bool = false
    
    var favExhibitionId: String?
    var isFavExhibition: Bool = false
    
    @State private var localImageFileURL: URL? = nil
    @State private var isLoadingLocalFile = false
    
    func animateMapAppearance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 1.5)) {
            mapHeight = 140
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.cameraTrigger.toggle()
        }
    }
    
    private func isOnlineAddress(_ addr: String?) -> Bool {
        guard let s = addr?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return false }
        return s == "online"
    }
    
    private func refreshData() async {
        isRefreshing = true
        try? await Task.sleep(for: .seconds(0.8))
        loadData()
        isRefreshing = false
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
                    if !isOnlineAddress(address) {
                        mapVM.showAddress(for: address)
                    } else {
                        mapVM.coordinate = nil
                        showMap = false
                    }
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
    
    func downloadImageFile() async {
        guard let urlString = exhibitionVM.exhibition?.posterImagePathUrl,
              let url = URL(string: urlString) else {
            print("Invalid or missing image URL")
            return
        }
        
        isLoadingLocalFile = true
        defer { isLoadingLocalFile = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create UIImage")
                return
            }
            
            // 임시 디렉토리에 파일로 저장
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("exhibition_poster.jpg")
            
            if let jpegData = image.jpegData(compressionQuality: 1.0) {
                try jpegData.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async {
                    localImageFileURL = fileURL
                }
            }
        } catch {
            print("Image download or save error: \(error)")
        }
    }
    
    func shareExhibitionToInstagram() {
        guard let exhibition = exhibitionVM.exhibition,
              let imageUrlString = exhibition.posterImagePathUrl,
              let imageURL = URL(string: imageUrlString) else {
            print("이미지 URL 없음")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                guard let stickerImage = UIImage(data: data) else {
                    print("스티커 이미지 변환 실패")
                    return
                }
                
                // 배경 이미지 (검정색 Rectangle)
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1080, height: 1920))
                let backgroundImage = renderer.image { context in
                    UIColor.black.setFill()
                    context.fill(CGRect(x: 0, y: 0, width: 1080, height: 1920))
                }
                
                shareToInstagram(background: backgroundImage, sticker: stickerImage, link: "https://google.com")
            } catch {
                print("이미지 로드 실패:", error)
            }
        }
    }
    
    private func shareToInstagram(background: UIImage?, sticker: UIImage?, link: String) {
        guard let background,
              let sticker,
              let bgData = background.pngData(),
              let stickerData = sticker.pngData() else {
            print("이미지 PNG 변환 실패")
            return
        }
        
        guard let facebookAppID = Bundle.main.infoDictionary?["FacebookAppID"] as? String else {
            print("FacebookAppID not found in Info.plist")
            return
        }
        let urlString = "instagram-stories://share?source_application=\(facebookAppID)"
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            print("인스타그램 앱이 설치되어 있지 않거나 URL 스킴 실패")
            withAnimation(.spring(response: 0.3)) {
                showShareAlert = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 0.3)) {
                    showShareAlert = false
                }
            }
            return
        }
        
        var pasteboardItems: [[String: Any]] = [[
            "com.instagram.sharedSticker.backgroundImage": bgData,
            "com.instagram.sharedSticker.stickerImage": stickerData,
            "com.instagram.sharedSticker.contentURL": link
        ]]
        
        // 링크가 있을 경우 content URL 추가 가능
        if !link.isEmpty {
            pasteboardItems[0]["com.instagram.sharedSticker.contentURL"] = link
        }
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(300)
        ]
        
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        UIApplication.shared.open(url, options: [:])
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .navigationBarBackButtonHidden()
            } else if let exhibition = exhibitionVM.exhibition {
                ScrollView {
                    let gid = "poster-\(exhibition.id)"
                    
                    AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 240, alignment: .center)
                            .clipShape(.rect(cornerRadius: 8))
                            .if(!isZoomed) { view in
                                view.matchedGeometryEffect(id: gid, in: fullPosterNS)
                            }
                            .opacity(isZoomed ? 0 : 1)
//                            .matchedGeometryEffect(id: gid, in: fullPosterNS)
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    currentImage = image
                                    isZoomed.toggle()
                                }
                            }
                    } placeholder: {
                        VStack {
                            placeholderImage
                                .renderingMode(.template)
                                
                            Text("No Poster but Peace")
                                .font(.objectivityFootnote)
                                .offset(y: -25)
                        }
                        .foregroundStyle(Color.secondAccent)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                    }
                    .padding(.bottom, 10)
                    
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.redacted)
                        
                        HStack(spacing: 10) {
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "heart")
                                    .imageScale(.large)
                            }
                            
                            Spacer()
                            
                            Button {
                                shareExhibitionToInstagram()
                            } label: {
                                Image("instagram-logo")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.accent)
                                    .frame(width: 22, height: 22)
                            }
                            
                            Spacer()
                            
                            if let fileURL = localImageFileURL {
                                ShareLink(item: fileURL, subject: Text("Share the Dot"), message: Text("its time to share the inspiration")) {
                                    Image(systemName: "square.and.arrow.up")
                                        .imageScale(.large)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .padding()
                    
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
                                
                                InfoDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)", textColor: .accent2)
                            }
                            
                            if let openingTimeFrom = exhibition.openingTimeFrom,
                               let openingTimeTo = exhibition.openingTimeTo {
                                let dateFormatter = DateFormatter.timeOnlyFormatter()
                                
                                let formattedOpeningTimeFrom = dateFormatter.string(from: openingTimeFrom)
                                let formattedOpeningTimeTo = dateFormatter.string(from: openingTimeTo)
                                
                                InfoDetailView(icon: "clock", text: "\(formattedOpeningTimeFrom) - \(formattedOpeningTimeTo)", textColor: .accent2)
                            }
                            
                            InfoDetailView(icon: "xmark.circle", text: exhibition.closingDays ?? ["Always open"], textColor: .accent2)
                            
                            InfoDetailView(icon: "location.circle", text: exhibition.address ?? "Unknown", textColor: .accent2)
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
//                                let region = MKCoordinateRegion(
//                                    center: coordinate,
//                                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
//                                )
//                                let camera = MapCamera(centerCoordinate: coordinate, distance: 300)
                                
                                if showMap {
                                    ZStack {
                                        Map(position: $cameraPosition) {
                                            Annotation("", coordinate: coordinate, anchor: .bottom) {
                                                Image(systemName: "smallcircle.filled.circle")
                                                    .font(.title3)
                                                    .foregroundStyle(Color.accent)
                                                    .symbolEffect(.pulse)
                                            }
                                        }
                                        .mapCameraKeyframeAnimator(trigger: cameraTrigger) { camera in
                                            KeyframeTrack(\.centerCoordinate) {
                                                // move camera position
                                                CubicKeyframe(coordinate, duration: 0.5)
                                            }
                                            KeyframeTrack(\.distance) {
                                                // zoom in
                                                CubicKeyframe(500, duration: 0.5)
                                            }
                                        }
                                        .frame(height: mapHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .disabled(true)
                                        .onAppear {
                                            animateMapAppearance()
                                        }
                                        .onReceive(mapVM.$coordinate.compactMap { $0 }) { coord in
                                            cameraPosition = .camera(MapCamera(centerCoordinate: coord, distance: 500))
                                        }
                                        
                                        Color.clear
                                            .contentShape(Rectangle())
                                            .onTapGesture {
//                                                mapVM.openMapAtCoordinate(coordinate, name: exhibition.title)
                                                mapVM.openMap(coordinate, name: exhibition.title)
                                            }
                                    }
                                    
                                    Divider()
                                } else {
                                    InfoDetailView(icon: "map.circle", text: "View Map", textColor: .accent2)
                                        .onTapGesture {
                                            showMap = true
                                        }
                                }
                            } else {
                                if let address = exhibition.address, address == "Online",
                                   let urlString = exhibition.onlineLink, let url = URL(string: urlString) {
                                    Button {
                                        pendingURL = url
                                        showLinkAlert = true
                                    } label: {
                                        InfoDetailView(icon: "link.circle", text: "\(url)", textColor: .accent2)
                                    }
                                    .alert("Open this link in your browser?", isPresented: $showLinkAlert, presenting: pendingURL) { url in
                                        Button("Cancel", role: .cancel) {
                                            pendingURL = nil
                                        }
                                        Button("Open") {
                                            openURL(url)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redacted)
                        .clipShape(.rect(cornerRadius: 8))
                        
                        SimpleExpandableTextView(text: exhibition.description ?? "")
                            .padding(.bottom, 10)
                        
                        Text(copyrightNotice)
                            .font(.objectivityFootnote)
                            .foregroundStyle(Color.secondAccent)
                            .lineSpacing(3)
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarBackButton()
                    
                    CompatibleToolbarItem(placement: .topBarTrailing) {
                        if let fileURL = localImageFileURL {
                            ShareLink(item: fileURL, subject: Text("Share the Dot"), message: Text("its time to share the inspiration")) {
                                Label("Share Poster", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Menu {
                            Button(action: {
                                shareExhibitionToInstagram()
                            }) {
                                HStack {
                                    Text("Share Story")
                                    
                                    Image("instagram-logo")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.accent)
                                        .frame(width: 10, height: 10)
                                }
                            }
                            
                            if let fileURL = localImageFileURL {
                                ShareLink(item: fileURL, subject: Text("Share the Dot"), message: Text("its time to share the inspiration")) {
                                    Label("Share Poster", systemImage: "square.and.arrow.up")
                                }
                            }
                            
                            if isMyExhibition {
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
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                        }
                    }
                }
                .refreshable(action: {
                    await refreshData()
                })
                .onAppear {
                    UINavigationController.swizzleIfNeeded()
                    if localImageFileURL == nil {
                        Task {
                            await downloadImageFile()
                        }
                    }
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
                .overlay {
                    Group {
                        if isZoomed, let image = currentImage {
                            FullScreenPosterView(
                                isZoomed: $isZoomed,
                                image: image,
                                posterNamespace: fullPosterNS,
                                geometryId: "poster-\(exhibition.id)"
                            )
                            .transition(.identity) // matchedGeometryEffect와 충돌 방지
                            .zIndex(1)
                        }
                    }
                }
            } else {
                Text("Unable to load exhibition information")
            }
            if showShareAlert {
                VStack {
                    BannerMessage(text: "Instagram app not found")
                    Spacer()
                }
                .padding(.top, 200)
            }
            
            if showCopyMessage {
                VStack {
                    BannerMessage(text: "Copied to clipboard")
                    Spacer()
                }
                .padding(.top, 200)
            }
        }
        .toolbar(isZoomed ? .hidden : .automatic, for: .navigationBar)
        .onAppear {
            loadData()
        }
        .viewBackground()
    }
}


struct InfoDetailView<T: CustomStringConvertible>: View {
    var icon: String
    var text: T
    var textColor: Color? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
                if let textColor {
                    if let arrayText = text as? [String] {
                        // 배열일 경우 문자열로 조인
                        Text(arrayText.joined(separator: ", "))
                            .foregroundStyle(textColor)
                    } else {
                        // 아닐 경우 문자열 그대로 출력
                        Text(String(describing: text))
                            .foregroundStyle(textColor)
                    }
                } else {
                    if let arrayText = text as? [String] {
                        // 배열일 경우 문자열로 조인
                        Text(arrayText.joined(separator: ", "))
                    } else {
                        // 아닐 경우 문자열 그대로 출력
                        Text(String(describing: text))
                    }
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

