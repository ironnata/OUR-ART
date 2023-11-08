//
//  ExhibitionManager.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ExhibitionArray: Codable {
    let exhibitions: [Exhibition]
    
}

struct Exhibition: Identifiable, Codable {
    let id: Int
    let title: String?
    let description: String?
    let date: String? // 일시적 String으로 설정
    let address: String?
    let openingTime: String? // 일시적 String으로 설정
    let closingDays: [String]?
    let thumbnail: String?
    let images: [String]?
}


final class ExhibitionManager {
    
    static let shared = ExhibitionManager()
    private init() { }
    
    private let exhibitionsCollection = Firestore.firestore().collection("exhibitions")
    
    private func exhibitionDocument(exhibitionId: String) -> DocumentReference {
        exhibitionsCollection.document(exhibitionId)
    }
    
    func uploadExhibition(exhibition: Exhibition) async throws {
        try exhibitionDocument(exhibitionId: String(exhibition.id)).setData(from: exhibition, merge: false)
    }
    
    func getExhibition(exhibitionId: String) async throws -> Exhibition {
        try await exhibitionDocument(exhibitionId: exhibitionId).getDocument(as: Exhibition.self)
    }
    
    func getAllExhibitions() async throws -> [Exhibition] {
        try await exhibitionsCollection.getDocuments(as: Exhibition.self)
    }
    
}


extension Query {
    
    // T = Type
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
}
