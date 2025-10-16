//
//  Extensions.swift
//  OurArt
//
//  Created by Jongmo You on 04.04.24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import UIKit


extension Query {
    
    // T = Type
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        let snapshot = try await self.getDocuments()
//
//        return try snapshot.documents.map({ document in
//            try document.data(as: T.self)
//        })
//    }
    
    // For Pagination
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).exhibitions
    }
    
    // For Pagination
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (exhibitions: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let exhibitions = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (exhibitions, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let exhibitions: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            publisher.send(exhibitions)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
}

extension Font {
    
    static let objectivityTitle = Font.custom("Objectivity-Bold", size: 26)
    
    static let objectivityTitle2 = Font.custom("Objectivity-Bold", size: 23)
    
    static let objectivityBody = Font.custom("Objectivity-Medium", size: 17)
    
    static let objectivityThinBody = Font.custom("Objectivity-Regular", size: 17)
    
    static let objectivityCallout = Font.custom("Objectivity-Regular", size: 15)
    
    static let objectivityFootnote = Font.custom("Objectivity-Regular", size: 13)
    
    static let objectivityCaption = Font.custom("Objectivity-Bold", size: 8)
    
}

extension DateFormatter {
    static func localizedDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    static func timeOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

extension View {
    func sectionBackground() -> some View {
        self.listRowBackground(Color.background0)
    }
    
    func viewBackground() -> some View {
        ZStack {
            Color.background0
                .ignoresSafeArea()
            
            self
        }
    }
    
    func toolbarBackground() -> some View {
        self.toolbarBackground(.background0, for: .tabBar, .automatic)
    }
    
    func sectionHeaderBackground() -> some View {
        modifier(SectionHeaderBackgroundColormodifier())
    }
    
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
    
    func showClearButton(_ text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(fieldText: text))
    }
    
    func logoImageAuth() -> some View {
        let uiImage = UIImage(named: (UITraitCollection.current.userInterfaceStyle == .light) ? "Logo-512-light" : "Logo-512") ?? UIImage()
        
        return Image(uiImage: uiImage)
            .resizable()
            .frame(width: 114, height: 114)
            .clipShape(.rect(cornerRadius: 18))
    }
    
    func logoImageHome() -> some View {
        let uiImage = UIImage(named: (UITraitCollection.current.userInterfaceStyle == .dark) ? "Logo-512" : "Logo-512-light") ?? UIImage()
        
        return Image(uiImage: uiImage)
            .resizable()
            .frame(width: 50, height: 50)
    }
    
    func logoImageSettings() -> some View {
        let uiImage = UIImage(named: (UITraitCollection.current.userInterfaceStyle == .light) ? "Logo-512" : "Logo-512-light") ?? UIImage()
        
        return Image(uiImage: uiImage)
            .resizable()
            .frame(width: 25, height: 25)
            .clipShape(.rect(cornerRadius: 4))
    }
    
    func zoomable(isZoomed: Binding<Bool>) -> some View {
        modifier(ZoomableModifier(isZoomed: isZoomed))
    }
    
    func keyboardAware(minDistance: CGFloat = 32) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAware(minDistance: minDistance))
    }
    
    @ViewBuilder
    func setUpTab(_ tab: Tab) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
            .toolbar(.hidden, for: .tabBar)
    }
}

// 네비게이션스택 드래그하여 뒤로가기
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension ToolbarItem {
    func apply<Content: ToolbarContent>(@ToolbarContentBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

// 새 아이폰 나올 때마다 switch문 수동 업데이트
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        // iPhone 17 series
        case "iPhone18,1": return "iPhone 17 Pro"
        case "iPhone18,2": return "iPhone 17 Pro Max"
        case "iPhone18,3": return "iPhone 17"
        case "iPhone18,4": return "iPhone Air"
        // iPhone 16 series
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"
        case "iPhone17,5": return "iPhone 16e"
        // iPhone 15 series
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        // iPhone 14 series
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        // iPhone 13 series
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        // iPhone SE (3rd Gen)
        case "iPhone14,6": return "iPhone SE (3rd generation)"
        // iPhone 12 series
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        // iPhone SE (2nd Gen)
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        // iPhone 11 series
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        // iPhone XR/XS
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        // iPhone X/8
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        // iPhone 7
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        // iPhone SE
        case "iPhone8,4": return "iPhone SE"
        // iPhone 6/6S
        case "iPhone8,1": return "iPhone 6S"
        case "iPhone8,2": return "iPhone 6S Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        // iPhone 5 series
        case "iPhone6,1", "iPhone6,2": return "iPhone 5S"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5C"
        default: return identifier
        }
    }
}
