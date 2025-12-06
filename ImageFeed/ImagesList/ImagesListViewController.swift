//
//  ViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.10.25.
//

import UIKit
import Kingfisher

private let showSingleImageSegueIdentifier = "ShowSingleImage"

final class ImagesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
	
	private let imagesListService = ImagesListService()
    private var notificationsTask: Task<Void, Never>?
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // TODO: Temporary initial fetch to ensure first page loads if service doesn't auto-start
        Task { [weak self] in
            // If fetchPhotosNextPage is async, 'await' is fine; if not, it's still safe to call here
            self?.imagesListService.fetchPhotosNextPage()
        }

        notificationsTask = Task { [weak self] in
            guard let self else { return }
            for await _ in NotificationCenter.default.notifications(named: ImagesListService.didChangeNotification) {
                await MainActor.run { self.updateTableViewAnimated() }
            }
        }
    }
    
    deinit {
        notificationsTask?.cancel()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
	
	private func dateText(for date: Date?) -> String {
	    date.map { dateFormatter.string(from: $0) } ?? ""
	}

	private func cellHeight(for tableView: UITableView, photo: Photo) -> CGFloat {
	    let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
	    let width = tableView.bounds.width - insets.left - insets.right
	    let w = CGFloat(photo.width)
	    let h = CGFloat(photo.height)
	    let aspect = (w > 0) ? (h / w) : 1.0
	    return width * aspect + insets.top + insets.bottom
	}

	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
	    let photo = imagesListService.photos[indexPath.row]
        cell.delegate = self

	    cell.cellImage.kf.indicatorType = .activity
	    let placeholder = UIImage(named: "imagesListPlaceholder")
	    let isLiked = photo.isLiked
	    let text = dateText(for: photo.createdAt)

	    if let placeholder { cell.configure(image: placeholder, dateText: text, isLiked: isLiked) }

	    let preferredURLString = photo.regularImageURL ?? photo.thumbImageURL
        guard let urlString = preferredURLString, let url = URL(string: urlString) else { return }

	    cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { _ in }
        cell.likeButton.isSelected = photo.isLiked
	}
	
	func updateTableViewAnimated() {
		let oldCount = tableView.numberOfRows(inSection: 0)
		let newCount = imagesListService.photos.count
		guard newCount > oldCount else { return }

		let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
		tableView.performBatchUpdates {
			tableView.insertRows(at: indexPaths, with: .automatic)
		}
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = imagesListService.photos[indexPath.row]
            let preferredURLString = photo.largeImageURL ?? photo.regularImageURL ?? photo.thumbImageURL
            if let urlString = preferredURLString, let url = URL(string: urlString) {
                viewController.imageURL = url
            } else {
                let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell
                viewController.image = cell?.cellImage.image
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
	
	func tableView(
	  _ tableView: UITableView,
	  willDisplay cell: UITableViewCell,
	  forRowAt indexPath: IndexPath
	) {
		if indexPath.row + 1 == imagesListService.photos.count {
			Task { [weak self] in
				self?.imagesListService.fetchPhotosNextPage()
			}
		}
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(for: tableView, photo: imagesListService.photos[indexPath.row])
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let current = imagesListService.photos[indexPath.row]
        let optimisticValue = !current.isLiked
		
        cell.likeButton.isEnabled = false
        cell.likeButton.isSelected = optimisticValue

        UIBlockingProgressHUD.show()

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await imagesListService.changeLike(photoId: current.id, isLike: optimisticValue)
                await MainActor.run {
                    UIBlockingProgressHUD.dismiss()
                    cell.likeButton.isEnabled = true
                }
            } catch {
                await MainActor.run {
                    UIBlockingProgressHUD.dismiss()
                    cell.likeButton.isSelected = current.isLiked
                    cell.likeButton.isEnabled = true
                    self.showErrorAlert(message: (error as NSError).localizedDescription)
                }
            }
        }
    }
}
