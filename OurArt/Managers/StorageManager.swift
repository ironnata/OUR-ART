//
//  StorageManager.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.23.


import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    // "이미지" / 저장
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    // 유저 / 각 유저 / 저장
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    // 전시 (포스터) / 저장
    private func exhibitionReference(exhibitionId: String) -> StorageReference {
        storage.child("exhibitions").child(exhibitionId)
    }
    
    func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    func getData(userId: String, path: String) async throws -> Data {
        // try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    // MARK: - PROFILE IMAGES
    
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        guard let image = UIImage(data: data),
              let processedData = image.jpegData(compressionQuality: 0.7) else {
            throw URLError(.badServerResponse)
        }
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(processedData, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    // 이미지를 직접 저정해야하는 경우 사용 ex) 카메라로 직접 찍은 사진, 앱 내에서 생성된 이미지를 저장, 이미지 편집 후 저장 시
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        // image.pngData()
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, userId: userId)
    }
    
    // MARK: - DELETE FUNCs
    
    func deleteImage(path: String) async throws {
        try await getPathForImage(path: path).delete()
    }
    
    func deleteUserImageFolder(userId: String) async throws {
        let listResults = try await userReference(userId: userId).list(maxResults: 1000)
        
        for item in listResults.items {
            try await item.delete()
        }
    }
    
    func deleteExhibitionImageFolder(exhibitionId: String) async throws {
        let listResults = try await exhibitionReference(exhibitionId: exhibitionId).list(maxResults: 1000)
        
        for item in listResults.items {
            try await item.delete()
        }
    }
    
    
    // MARK: - POSTERS
    
    func savePoster(data: Data, exhibitionId: String) async throws -> (path: String, name: String) {
        guard let image = UIImage(data: data),
              let processedData = image.jpegData(compressionQuality: 0.7) else {
            throw URLError(.badServerResponse)
        }
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await exhibitionReference(exhibitionId: exhibitionId).child(path).putDataAsync(processedData, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    // 이미지를 직접 저정해야하는 경우 사용 ex) 카메라로 직접 찍은 사진, 앱 내에서 생성된 이미지를 저장, 이미지 편집 후 저장 시
    func savePoster(image: UIImage, exhibitionId: String) async throws -> (path: String, name: String) {
        // image.pngData()
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await savePoster(data: data, exhibitionId: exhibitionId)
    }
}
