//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 09.10.25.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction private func likeTapped(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.isSelected = false
		cellImage.kf.cancelDownloadTask()
    }
    
    func configure(image: UIImage, dateText: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = dateText
        likeButton.isSelected = isLiked
        
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
    }
}
