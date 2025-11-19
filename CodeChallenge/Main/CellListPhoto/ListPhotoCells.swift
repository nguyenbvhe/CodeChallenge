//
//  ListPhotoCells.swift
//  CodeChallenge
//
//  Created by minhnguyen on 19/11/25.
//


import UIKit

class ListPhotoCells: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImage.contentMode = .scaleAspectFill
        photoImage.clipsToBounds = true
        // loading center
        photoImage.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: photoImage.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImage.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = nil
        authorLabel.text = nil
        sizeLabel.text = nil
       // imageHeightConstraint.constant = 150 // reset height image
        activityIndicator.startAnimating()
    }
    
    // configure cell   
    func configure(with photo: ListPhotos) {
        authorLabel.text = photo.author
        sizeLabel.text = "\(photo.width) × \(photo.height)"
        
        activityIndicator.startAnimating()
        
        let ratio = CGFloat(photo.height) / CGFloat(photo.width)
        let availableWidth = UIScreen.main.bounds.width - 32
        let calculatedHeight = max(100, ratio * availableWidth)  // không nhỏ hơn 100
        
        // Set lại height ĐÚNG LUÔN, không chờ gì nữa
        imageHeightConstraint.constant = calculatedHeight
        
       // layout update before tableview calculate height
        DispatchQueue.main.async {
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
        
        loadImage(from: photo.downloadURL)
    }
    
    private func loadImage(from originalURL: String) {
        // Lấy id và ép về 800px rộng
        if let id = originalURL.components(separatedBy: "/id/").last?.components(separatedBy: "/").first,
           let _ = Int(id) {
            let safeURL = "https://picsum.photos/id/\(id)/800"
            let url = URL(string: safeURL)!
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.photoImage.image = image
                    self?.activityIndicator.stopAnimating()
                }
            }.resume()
        }
    }
}
