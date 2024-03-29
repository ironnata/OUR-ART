//
//  ExhibitionManager.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct Exhibition: Identifiable, Codable {
    var id: String
    let dateCreated: Date?
    let title: String?
    let artist: String?
    let description: String?
    let dateFrom: Date?
    let dateTo: Date?
    let address: String?
    let openingTimeFrom: Date?
    let openingTimeTo: Date?
    let closingDays: [String]?
    let thumbnail: String?
    let images: [String]?
    let posterImagePath: String?
    let posterImagePathUrl: String?
    
    init(
        id: String,
        dateCreated: Date? = nil,
        title: String? = nil,
        artist: String? = nil,
        description: String? = nil,
        dateFrom: Date? = nil,
        dateTo: Date? = nil,
        address: String? = nil,
        openingTimeFrom: Date? = nil,
        openingTimeTo: Date? = nil,
        closingDays: [String]? = nil,
        thumbnail: String? = nil,
        images: [String]? = nil,
        posterImagePath: String? = nil,
        posterImagePathUrl: String? = nil
    ) {
        self.id = id
        self.dateCreated = dateCreated
        self.title = title
        self.artist = artist
        self.description = description
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.address = address
        self.openingTimeFrom = openingTimeFrom
        self.openingTimeTo = openingTimeTo
        self.closingDays = closingDays
        self.thumbnail = thumbnail
        self.images = images
        self.posterImagePath = posterImagePath
        self.posterImagePathUrl = posterImagePathUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateCreated = "date_created"
        case title = "title"
        case artist = "artist"
        case description = "description"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case address = "address"
        case openingTimeFrom = "opening_time_from"
        case openingTimeTo = "opening_time_to"
        case closingDays = "closing_days"
        case thumbnail = "thumbnail"
        case images = "images"
        case posterImagePath = "poster_image_path"
        case posterImagePathUrl = "poster_image_path_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.artist = try container.decodeIfPresent(String.self, forKey: .artist)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.dateFrom = try container.decodeIfPresent(Date.self, forKey: .dateFrom)
        self.dateTo = try container.decodeIfPresent(Date.self, forKey: .dateTo)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.openingTimeFrom = try container.decodeIfPresent(Date.self, forKey: .openingTimeFrom)
        self.openingTimeTo = try container.decodeIfPresent(Date.self, forKey: .openingTimeTo)
        self.closingDays = try container.decodeIfPresent([String].self, forKey: .closingDays)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.images = try container.decodeIfPresent([String].self, forKey: .images)
        self.posterImagePath = try container.decodeIfPresent(String.self, forKey: .posterImagePath)
        self.posterImagePathUrl = try container.decodeIfPresent(String.self, forKey: .posterImagePathUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.artist, forKey: .artist)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.dateFrom, forKey: .dateFrom)
        try container.encodeIfPresent(self.dateTo, forKey: .dateTo)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.openingTimeFrom, forKey: .openingTimeFrom)
        try container.encodeIfPresent(self.openingTimeTo, forKey: .openingTimeTo)
        try container.encodeIfPresent(self.closingDays, forKey: .closingDays)
        try container.encodeIfPresent(self.thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(self.images, forKey: .images)
        try container.encodeIfPresent(self.posterImagePath, forKey: .posterImagePath)
        try container.encodeIfPresent(self.posterImagePathUrl, forKey: .posterImagePathUrl)
    }
}


final class ExhibitionManager {
    
    static let shared = ExhibitionManager()
    private init() { }
    
    private let exhibitionsCollection = Firestore.firestore().collection("exhibitions")
    
    private func exhibitionDocument(id: String) -> DocumentReference {
        exhibitionsCollection.document(id)
    }
    
    func createExhibition(exhibition: Exhibition) async throws {
        try exhibitionDocument(id: exhibition.id).setData(from: exhibition, merge: false)
    }
    
    // 나중에 쓸 favorite or myExhibitons 기능!
//    func updateExhibition(exhibitionId: String, exhibition: Exhibition) async throws {
//        guard let data = try? encoder.encode(exhibition) else {
//            throw URLError(.badURL)
//        }
//        
//        let dict: [String:Any?] = [
//            Exhibition.CodingKeys.title.rawValue : title
//        ]
//        
//        try await exhibitionDocument(exhibitionId: exhibitionId).updateData(data as [AnyHashable : Any])
//    }
    
    func getExhibition(id: String) async throws -> Exhibition {
        try await exhibitionDocument(id: id).getDocument(as: Exhibition.self)
    }
    
    func getAllExhibitions() async throws -> [Exhibition] {
        try await exhibitionsCollection.getDocuments(as: Exhibition.self)
    }
    
    // addArtist func
    func addArtist(exhibitionId: String, artist: String) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.artist.rawValue : artist
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    // addDate func
    func addDate(exhibitionId: String, dateFrom: Date, dateTo: Date) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.dateFrom.rawValue : dateFrom,
            Exhibition.CodingKeys.dateTo.rawValue : dateTo
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    // addAddress func
    func addAddress(exhibitionId: String, address: String) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.address.rawValue : address
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    // addOpeningHours func
    func addOpeningHours(exhibitionId: String, openingHoursFrom: Date, openingHoursTo: Date) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.openingTimeFrom.rawValue : openingHoursFrom,
            Exhibition.CodingKeys.openingTimeTo.rawValue : openingHoursTo
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    // addClosingDays func
    func addClosingDaysPreference(exhibitionId: String, closingDays: String) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.closingDays.rawValue : FieldValue.arrayUnion([closingDays])
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    func removeClosingDaysPreference(exhibitionId: String, closingDays: String) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.closingDays.rawValue : FieldValue.arrayRemove([closingDays])
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    // addDiscription func
    func addDescription(exhibitionId: String, description: String) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.description.rawValue : description
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    
    func updateUserPosterImagePath(exhibitionId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            Exhibition.CodingKeys.posterImagePath.rawValue : path,
            Exhibition.CodingKeys.posterImagePathUrl.rawValue : url,
        ]
        
        try await exhibitionDocument(id: exhibitionId).updateData(data)
    }
    
    func deleteExhibition(exhibitionId: String) async throws {
        try await exhibitionDocument(id: exhibitionId).delete()
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
