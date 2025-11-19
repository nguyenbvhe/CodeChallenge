//
//  ListPhotos.swift
//  CodeChallenge
//
//  Created by minhnguyen on 19/11/25.
//

import Foundation

struct ListPhotos: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}

// Extension để View dễ dùng
extension ListPhotos {
    var sizeText: String {
        "\(width) × \(height)"
    }
    
    func calculatedHeight(for width: CGFloat) -> CGFloat {
        let ratio = CGFloat(height) / CGFloat(width)
        return max(100, ratio * width)
    }
}
