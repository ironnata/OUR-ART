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
    
    static let objectivityLargeTitle = Font.custom("Objectivity-Bold", size: 32)
    
    static let objectivityTitle = Font.custom("Objectivity-Bold", size: 28)
    
    static let objectivityTitle2 = Font.custom("Objectivity-Bold", size: 23)
    
    static let objectivityBody = Font.custom("Objectivity-Medium", size: 17)
    
    static let objectivityCallout = Font.custom("Objectivity-Regular", size: 15)
    
    static let objectivityFootnote = Font.custom("Objectivity-Regular", size: 13)
    
    static let objectivityCaption = Font.custom("Objectivity-Regular", size: 10)
    
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
        self.background(.background0)
    }
    
    func customNavigationBar() -> some View {
        self.modifier(CustomNavigationBar())
    }
    
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}



struct CustomNavigationBar: ViewModifier {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Objectivity-ExtraBold", size: 32)!]
        
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Objectivity-Bold", size: 17)!]
    }
    
    func body(content: Content) -> some View {
        content
    }
}

