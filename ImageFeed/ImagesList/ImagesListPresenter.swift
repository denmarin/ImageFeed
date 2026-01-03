//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.01.26.
//

import UIKit
import Foundation
import Kingfisher

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var numberOfRows: Int { get }
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath)
    func cellHeight(for tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func didTapLike(at indexPath: IndexPath)
    func imageURLForDetails(at indexPath: IndexPath) -> URL?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    private let imagesListService: ImagesListService
    private var notificationsTask: Task<Void, Never>?
    private let helper = ImagesListHelper()

    init(imagesListService: ImagesListService = .shared) {
        self.imagesListService = imagesListService
    }

    var numberOfRows: Int { imagesListService.photos.count }
	private var lastPhotosCount = 0

	func viewDidLoad() {
		lastPhotosCount = imagesListService.photos.count
		bindNotifications()
		imagesListService.fetchPhotosNextPage()
	}

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        cell.delegate = nil // delegate set by VC
        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "imagesListPlaceholder")
        let isLiked = photo.isLiked
        let text = helper.dateText(for: photo.createdAt)
        if let placeholder { cell.configure(image: placeholder, dateText: text, isLiked: isLiked) }
        let preferredURLString = photo.regularImageURL ?? photo.thumbImageURL
        if let urlString = preferredURLString, let url = URL(string: urlString) {
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { _ in }
        }
        cell.likeButton.isSelected = photo.isLiked
    }

    func cellHeight(for tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        return helper.cellHeight(for: tableView, photo: photo)
    }

    func didTapLike(at indexPath: IndexPath) {
        let current = imagesListService.photos[indexPath.row]
        let optimisticValue = !current.isLiked
        view?.setLikeEnabled(false, at: indexPath)
        Task { [weak self] in
            guard let self else { return }
            UIBlockingProgressHUD.show()
            do {
                _ = try await imagesListService.changeLike(photoId: current.id, isLike: optimisticValue)
                await MainActor.run {
                    UIBlockingProgressHUD.dismiss()
                    self.view?.setLikeEnabled(true, at: indexPath)
                }
            } catch {
                await MainActor.run {
                    UIBlockingProgressHUD.dismiss()
                    self.view?.setLikeEnabled(true, at: indexPath)
                    self.view?.showError(message: (error as NSError).localizedDescription)
                }
            }
        }
    }

    func imageURLForDetails(at indexPath: IndexPath) -> URL? {
        let photo = imagesListService.photos[indexPath.row]
        let preferredURLString = photo.largeImageURL ?? photo.regularImageURL ?? photo.thumbImageURL
        if let urlString = preferredURLString, let url = URL(string: urlString) {
            return url
        }
        return nil
    }

	private func bindNotifications() {
		notificationsTask?.cancel()
		notificationsTask = Task { [weak self] in
			guard let self else { return }

			for await _ in NotificationCenter.default.notifications(named: ImagesListService.didChangeNotification) {
				let newCount = self.imagesListService.photos.count
				let oldCount = self.lastPhotosCount
				self.lastPhotosCount = newCount

				await MainActor.run {
					self.view?.reloadRows(from: oldCount, to: newCount)
				}
			}
		}
	}

    deinit {
        notificationsTask?.cancel()
    }
}

