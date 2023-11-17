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
    let id: String
    let title: String?
    let description: String?
    let date: Date?
    let address: String?
    let openingTime: Date?
    let closingDays: [String]?
    let thumbnail: String?
    let images: [String]?
    
    init(
        id: String,
        title: String? = nil,
        description: String? = nil,
        date: Date? = nil,
        address: String? = nil,
        openingTime: Date? = nil,
        closingDays: [String]? = nil,
        thumbnail: String? = nil,
        images: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.address = address
        self.openingTime = openingTime
        self.closingDays = closingDays
        self.thumbnail = thumbnail
        self.images = images
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case date = "date"
        case address = "address"
        case openingTime = "opening_time"
        case closingDays = "closing_days"
        case thumbnail = "thumbnail"
        case images = "images"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.openingTime = try container.decodeIfPresent(Date.self, forKey: .openingTime)
        self.closingDays = try container.decodeIfPresent([String].self, forKey: .closingDays)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.images = try container.decodeIfPresent([String].self, forKey: .images)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.date, forKey: .date)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.openingTime, forKey: .openingTime)
        try container.encodeIfPresent(self.closingDays, forKey: .closingDays)
        try container.encodeIfPresent(self.thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(self.images, forKey: .images)

    }
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
