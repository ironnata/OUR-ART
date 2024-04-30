//
//  UserManager.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - DB USER

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let preferences: [String]?
    let nickname: String?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.preferences = nil
        self.nickname = nil
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
    }
    
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        preferences: [String]? = nil,
        nickname: String? = nil,
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.preferences = preferences
        self.nickname = nickname
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
    }
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case preferences = "preferences"
        case nickname = "nickname"
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.nickname, forKey: .nickname)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)

    }
}


// MARK: - USER MANAGER

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userMyExhibitionCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("my_exhibitions")
    }
    
    private func userMyExhibitionDocument(userId: String, myExhibitionId: String) -> DocumentReference {
        userMyExhibitionCollection(userId: userId).document(myExhibitionId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func creatNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func loadUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true)
    }
    
//    func creatNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//
//        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    

    func addNickname(userId: String, nickname: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.nickname.rawValue : nickname
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }

    // MARK: - MY EXHIBITIONS
    
    func addMyExhibition(userId: String, exhibitionId: String) async throws {
        let exhibitionData = try await ExhibitionManager.shared.getExhibition(id: exhibitionId)
        
        let dateFrom = exhibitionData.dateFrom
        let posterImagePath = exhibitionData.posterImagePath
        
        let document = userMyExhibitionCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            UserMyExhibition.CodingKeys.id.rawValue : documentId,
            UserMyExhibition.CodingKeys.exhibitionId.rawValue : exhibitionId,
            UserMyExhibition.CodingKeys.dateCreated.rawValue : Timestamp(),
            UserMyExhibition.CodingKeys.dateFrom.rawValue : dateFrom,
            UserMyExhibition.CodingKeys.posterImagePath.rawValue : posterImagePath
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeMyExhibition(userId: String, myExhibitionId: String) async throws {
        try await userMyExhibitionDocument(userId: userId, myExhibitionId: myExhibitionId).delete()
    }
    
    func getAllMyExhibitions(userId: String) async throws -> [UserMyExhibition] {
        try await userMyExhibitionCollection(userId: userId).getDocuments(as: UserMyExhibition.self)
    }
}


struct UserMyExhibition: Codable {
    let id: String
    let exhibitionId: String
    let dateCreated: Date
    let dateFrom: Date?
    let posterImagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case exhibitionId = "exhibition_id"
        case dateCreated = "date_created"
        case dateFrom = "date_from"
        case posterImagePath = "poster_image_path"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.exhibitionId = try container.decode(String.self, forKey: .exhibitionId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.dateFrom = try container.decodeIfPresent(Date.self, forKey: .dateFrom)
        self.posterImagePath = try container.decodeIfPresent(String.self, forKey: .posterImagePath)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.exhibitionId, forKey: .exhibitionId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.dateFrom, forKey: .dateFrom)
        try container.encodeIfPresent(self.posterImagePath, forKey: .posterImagePath)
    }
}
