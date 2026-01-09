//
//  ImagesListHelper.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.01.26.
//

import UIKit

final class ImagesListHelper {
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func dateText(for date: Date?) -> String {
        date.map { dateFormatter.string(from: $0) } ?? ""
    }

    func cellHeight(for tableView: UITableView, photo: Photo) -> CGFloat {
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let width = tableView.bounds.width - insets.left - insets.right
        let w = CGFloat(photo.width)
        let h = CGFloat(photo.height)
        let aspect = (w > 0) ? (h / w) : 1.0
        return width * aspect + insets.top + insets.bottom
    }
}
