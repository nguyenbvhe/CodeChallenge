//
//  ListPhotoVM.swift
//  CodeChallenge
//
//  Created by minhnguyen on 19/11/25.
//

import Foundation
import UIKit

class PhotoListViewModel {
    private let photoService = PhotoService.shared
    
    private(set) var photos: [ListPhotos] = [] {
        didSet {
            heightCache.removeAll()
            updateHeightCache()
            onPhotosUpdated?()
        }
    }
    
    var onPhotosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private var heightCache: [IndexPath: CGFloat] = [:]
    
    func fetchPhotos() {
        photoService.fetchPhotos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    self?.photos = photos
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func numberOfRows() -> Int {
        return photos.count
    }
    
    func photo(at indexPath: IndexPath) -> ListPhotos {
        return photos[indexPath.row]
    }
    
    func estimatedHeight(at indexPath: IndexPath) -> CGFloat {
        return heightCache[indexPath] ?? 400
    }
    
    private func updateHeightCache() {
        let screenWidth = UIScreen.main.bounds.width - 32 // margin
        for (index, photo) in photos.enumerated() {
            let height = photo.calculatedHeight(for: screenWidth) + 80 // + label height
            heightCache[IndexPath(row: index, section: 0)] = height
        }
    }
}
