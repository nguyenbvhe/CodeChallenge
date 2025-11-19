//
//  PhotoService.swift
//  CodeChallenge
//
//  Created by minhnguyen on 19/11/25.
//

import Foundation
class PhotoService {
    static let shared = PhotoService()
    
    func fetchPhotos(completion: @escaping (Result<[ListPhotos], Error>) -> Void) {
        let urlString = "https://picsum.photos/v2/list?page=1&limit=100"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let photos = try JSONDecoder().decode([ListPhotos].self, from: data)
                completion(.success(photos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
