//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 09.10.25.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBAction private func likeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.isSelected = false
    }
    
    func configure(image: UIImage, dateText: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = dateText
        likeButton.isSelected = isLiked
        
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
    }
}
