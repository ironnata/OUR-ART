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
    
    static let objectivityCaption = Font.custom("Objectivity-Bold", size: 7)
    
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
