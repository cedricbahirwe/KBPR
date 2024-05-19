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

@MainActor
final class KBFBStorage {
    enum UploadError: Error {
        case unableTogetJPEGData
    }
    static let shared = KBFBStorage()
    
    var onUploadProgressChanged: ((Progress) -> Void)?
    
    private init() {
        
    }
    
    private let storage = Storage.storage()
    
    var randomID: String { UUID().uuidString }
    
    func uploadImage(_ image: UIImage, quality: CGFloat = 0.75) async throws -> ImageStoragePath {
        let imagPath = "images/\(randomID).jpg"
        let uploadRef = storage.reference().storage.reference(withPath: imagPath)
        
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            throw UploadError.unableTogetJPEGData
        }
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        do {
            
            let downloadedMetadata = try await uploadRef.putDataAsync(imageData, metadata: uploadMetadata) { progress in
                guard let progress else { return }
                print("You are at \(progress.fractionCompleted)")
                
                self.onUploadProgressChanged?(progress)
            }
            
            print("Put is complete and i got this back: \(downloadedMetadata)")
            
            
            return imagPath
            
        } catch {
            print("Oh no! Got an error \(error.localizedDescription)")
            throw error
        }
    }
    
    func getImageURL(_ imagePath: ImageStoragePath) async -> URL? {
        let storageRef = storage.reference().storage.reference(withPath: imagePath)
        
        do {
            let url = try await storageRef.downloadURL()
            print("url", url)
            return url
        } catch {
            print("Got an error url: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getImageData(_ imagePath: ImageStoragePath, maxSize: Int64 = 4 * 1020 * 1024) async -> Data? {
        let storageRef = storage.reference().storage.reference(withPath: imagePath)
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                storageRef.getData(maxSize: maxSize) { (result) in
                    continuation.resume(with: result)
                }
            }
        } catch {
            print("Got an error image data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadMovie(_ localMovieURL: URL) async throws -> VideoStoragePath {
        let videoPath = "/movies/\(randomID).mov"
        let uploadRef = storage.reference(withPath: videoPath)
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/quicktime"
        
        do {
            
            let downloadedMetadata = try await uploadRef.putFileAsync(from: localMovieURL, metadata: uploadMetadata) { progress in
                guard let progress else { return }
                print("Movie upload at \(progress.fractionCompleted)")
                
                self.onUploadProgressChanged?(progress)
            }
            
            print("Put movie is complete and : \(downloadedMetadata)")
            
            
            return videoPath
            
        } catch {
            print("Yikes! Got an error \(error.localizedDescription)")
            throw error
        }
    }
    
    func getMovie(_ moviePath: VideoStoragePath) async throws -> URL? {
        
        let fileManager = FileManager.default
        let documentDir = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let localFile = documentDir.appendingPathComponent("downloadedMovie.mox")
        
        let storageRef = storage.reference().storage.reference(withPath: moviePath)

        
        
        do {
            let fileURL = try await storageRef.writeAsync(toFile: localFile) { progress in
                guard let progress else { return }
                print("Movie download at at \(progress.fractionCompleted)")
                
                self.onUploadProgressChanged?(progress)
            }
            
            return fileURL
        } catch {
            print("Got an error movie url: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getMovieLink(_ moviePath: VideoStoragePath) async throws -> URL? {
        let videoPath = "/movies/\(randomID).mov"
        let storageRef = storage.reference(withPath: videoPath)
        
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
