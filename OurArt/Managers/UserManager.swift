//
//  UserManager.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

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
    
    private var userMyExhibitionsListener: ListenerRegistration? = nil
    
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
            DBUser.CodingKeys.profileImagePath.rawValue : path as Any,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url as Any,
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func deleteUser(userId: String) async throws {
        try await userDocument(userId: userId).delete()
    }

    // MARK: - MY EXHIBITIONS
    
    func addMyExhibition(userId: String, exhibitionId: String) async throws {
        let document = userMyExhibitionCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            UserMyExhibition.CodingKeys.id.rawValue : documentId,
            UserMyExhibition.CodingKeys.exhibitionId.rawValue : exhibitionId,
            UserMyExhibition.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func getMyExhibition(userId: String, myExhibitionId: String) async throws -> UserMyExhibition {
        try await userMyExhibitionDocument(userId: userId, myExhibitionId: myExhibitionId).getDocument(as: UserMyExhibition.self)
    }
    
    func removeMyExhibition(userId: String, myExhibitionId: String) async throws {
        try await userMyExhibitionDocument(userId: userId, myExhibitionId: myExhibitionId).delete()
    }
    
    func getAllMyExhibitions(userId: String) async throws -> [UserMyExhibition] {
        try await userMyExhibitionCollection(userId: userId).getDocuments(as: UserMyExhibition.self)
    }
    
//    func removeListenerForAllMyExhibitions() {
//        self.userMyExhibitionsListener?.remove()
//    }
    
//    func addListenerForAllUserMyExhibitions(userId: String, completion: @escaping (_ exhibitions: [UserMyExhibition]) -> Void) {
//        self.userMyExhibitionsListener = userMyExhibitionCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            let exhibitions: [UserMyExhibition] = documents.compactMap({ try? $0.data(as: UserMyExhibition.self) })
//            completion(exhibitions)
//        }
//    }
    
    // With Combine
//    func addListenerForAllUserMyExhibitions(userId: String) -> AnyPublisher<[UserMyExhibition], Error> {
//        let publisher = PassthroughSubject<[UserMyExhibition], Error>()
//        
//        self.userMyExhibitionsListener = userMyExhibitionCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            let exhibitions: [UserMyExhibition] = documents.compactMap({ try? $0.data(as: UserMyExhibition.self) })
//            publisher.send(exhibitions)
//        }
//        
//        return publisher.eraseToAnyPublisher()
//    }
    
    // With Combine + Query ////////// 전시 데이터 변경 시 UI즉시적용하는 방법을 못찾아 우선 사용 보류
    func addListenerForAllUserMyExhibitions(userId: String) -> AnyPublisher<[UserMyExhibition], Error> {
        let (publisher, listener) = userMyExhibitionCollection(userId: userId)
            .addSnapshotListener(as: UserMyExhibition.self)
        
        self.userMyExhibitionsListener = listener
        return publisher
    }
    
    func removeListenerForAllUserMyExhibitions() {
        self.userMyExhibitionsListener?.remove()
    }
}


struct UserMyExhibition: Codable, Identifiable {
    var id: String
    let exhibitionId: String
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case exhibitionId = "exhibition_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.exhibitionId = try container.decode(String.self, forKey: .exhibitionId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.exhibitionId, forKey: .exhibitionId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
}
