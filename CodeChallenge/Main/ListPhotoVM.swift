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
    
    private var allPhotos: [ListPhotos] = []
    private(set) var filteredPhotos: [ListPhotos] = [] {
        didSet {
            rebuildHeightCache()
            onPhotosUpdated?()
        }
    }
    
    var onPhotosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    /// Cache chiều cao theo filteredPhotos
    private var heightCache: [Int: CGFloat] = [:]
    
    private var searchTask: DispatchWorkItem?
    
    
    // MARK: - Fetch
    func fetchPhotos() {
        photoService.fetchPhotos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    self?.allPhotos = photos
                    self?.filteredPhotos = photos
                    
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: - Filter (debounce)
    func filterPhotos(with text: String) {
        
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            let query = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if query.isEmpty {
                filteredPhotos = allPhotos
            } else {
                filteredPhotos = allPhotos.filter {
                    $0.author.lowercased().contains(query) ||
                    $0.id.contains(query)
                }
            }
        }
        
        searchTask = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: task)
    }
    
    
    // MARK: - Table binding
    func numberOfRows() -> Int {
        filteredPhotos.count
    }
    
    func photo(at indexPath: IndexPath) -> ListPhotos {
        filteredPhotos[indexPath.row]
    }
    
    func estimatedHeight(at indexPath: IndexPath) -> CGFloat {
        return heightCache[indexPath.row] ?? 300
    }
    
    
    // MARK: - Cache Height
    private func rebuildHeightCache() {
        heightCache.removeAll()
        
        let screenWidth = UIScreen.main.bounds.width - 32
        
        for (index, photo) in filteredPhotos.enumerated() {
            
            let imageHeight = photo.calculatedHeight(for: screenWidth)
            let total = imageHeight + 80  // + label & padding
            
            heightCache[index] = total
        }
    }
}
