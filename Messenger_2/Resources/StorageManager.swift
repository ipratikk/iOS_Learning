//
//  StorageManager.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 26/02/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    // images/user@email-com_profile_picture.png
    public typealias uploadPictureCompletion = (Result<String,Error>) -> Void
    
    // Upload picture to firebase and return url to download
    public func uploadProfilePicture(with data: Data,fileName : String,completion : @escaping uploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil,completion: { [weak self] metadata,error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else{
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL : \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors : Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public func downloadURL(for path : String, completion : @escaping (Result<URL,Error>) -> Void){
        let reference = storage.child(path)
        reference.downloadURL(completion: {url , error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
    
}
