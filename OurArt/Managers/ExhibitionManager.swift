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
    let date: Date?
    let address: String?
    let openingTime: Date?
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
    
    func getAllExhibitions() async throws -> [Exhibition] {
        let snapshot = try await exhibitionsCollection.getDocuments()
        
        var exhibitions: [Exhibition] = []
        
        for document in snapshot.documents {
            let exhibition = try document.data(as: Exhibition.self)
            exhibitions.append(exhibition)
        }
        
        return exhibitions
    }
}
