//
//  KBFBStorage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 19/05/2024.
//

import Foundation
import FirebaseStorage
import UIKit


typealias ImageStoragePath = String
typealias VideoStoragePath = String

enum CacheKey: String {
    case userData
    case userProfilePic
    // Add more cases as needed
}

@MainActor
final class KBFBStorage {
    enum UploadError: Error {
        case unableTogetJPEGData
    }
    static let shared = KBFBStorage()
        
    private init() {}
    
    private let storage = Storage.storage()
    
    var randomID: String { UUID().uuidString }
    
    
    enum Path: String {
        case images, movies, profiles
    }
    
    func uploadImage(
        _ image: UIImage,
        path: KBFBStorage.Path = .images,
        quality: CGFloat = 0.75,
        progressHandler: ((Progress) -> Void)? = nil
    ) async throws -> ImageStoragePath {
        let imagPath = "\(path.rawValue)/\(randomID).jpg"
        let uploadRef = storage.reference(withPath: imagPath)
        
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            throw UploadError.unableTogetJPEGData
        }
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        do {
            
            let downloadedMetadata = try await uploadRef.putDataAsync(imageData, metadata: uploadMetadata) { progress in
                guard let progress else { return }
                print("You are at \(progress.fractionCompleted)")
                progressHandler?(progress)
            }
            
            print("Put is complete and i got this back: \(downloadedMetadata)")
            
            
            return imagPath
            
        } catch {
            print("Oh no! Got an error \(error.localizedDescription)")
            throw error
        }
    }
    
    func getImageURL(_ imagePath: ImageStoragePath) async -> URL? {
        let storageRef = storage.reference(withPath: imagePath)
        
        do {
            let url = try await storageRef.downloadURL()
            print("url", url)
            return url
        } catch {
            print("Got an error url: \(error.localizedDescription)")
            return nil
        }
    }
    
    private let imageCache = Cache<String, Data>()

    func getImageData(_ imagePath: ImageStoragePath, maxSize: Int64 = 4 * 1020 * 1024) async -> Data? {
        if let retrievedData = imageCache[imagePath] {
            return retrievedData
        }
        
        let storageRef = storage.reference(withPath: imagePath)
        
        do {
            let data = try await withCheckedThrowingContinuation { continuation in
                storageRef.getData(maxSize: maxSize) { (result) in
                    continuation.resume(with: result)
                }
            }
            
            imageCache[imagePath] = data
            return data
        } catch {
            print("Got an error image data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadMovie(
        _ localMovieURL: URL,
        path: KBFBStorage.Path = .movies,
        progressHandler: ((Progress) -> Void)? = nil
    ) async throws -> VideoStoragePath {
        let videoPath = "/\(path.rawValue)/\(randomID).mp4"
        let uploadRef = storage.reference(withPath: videoPath)
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        
        do {
            
            let downloadedMetadata = try await uploadRef.putFileAsync(from: localMovieURL, metadata: uploadMetadata) { progress in
                guard let progress else { return }
                print("Movie upload at \(progress.fractionCompleted)")
                progressHandler?(progress)
            }
            
            print("Put movie is complete and : \(downloadedMetadata)")
            
            
            return videoPath
            
        } catch {
            print("Yikes! Got an error \(error.localizedDescription)")
            throw error
        }
    }
    
    func getMovie(
        _ moviePath: VideoStoragePath,
        progressHandler: ((Progress) -> Void)? = nil
    ) async throws -> URL? {
        
        let fileManager = FileManager.default
        let documentDir = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let localFile = documentDir.appendingPathComponent("downloadedMovie.mp4")
        
        let storageRef = storage.reference(withPath: moviePath)
        
        do {
            let fileURL = try await storageRef.writeAsync(toFile: localFile) { progress in
                guard let progress else { return }
                print("Movie download at at \(progress.fractionCompleted)")
                progressHandler?(progress)
            }
            
            return fileURL
        } catch {
            print("Got an error movie url: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getMovieLink(_ moviePath: VideoStoragePath) async throws -> URL? {
        let storageRef = storage.reference(withPath: moviePath)
        
        do {
            let url = try await storageRef.downloadURL()
            print("url", url)
            return url
        } catch {
            print("Got an movie error url: \(error.localizedDescription)")
            return nil
        }
    }
}
