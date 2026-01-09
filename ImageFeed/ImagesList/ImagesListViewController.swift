//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.10.25.
//

import UIKit
import Kingfisher

private let showSingleImageSegueIdentifier = "ShowSingleImage"

// MARK: - Protocols
protocol ImagesListViewProtocol: AnyObject {
    func reloadRows(from oldCount: Int, to newCount: Int)
    func setLikeEnabled(_ enabled: Bool, at indexPath: IndexPath)
    func showError(message: String)
}

// MARK: - View Controller
final class ImagesListViewController: UIViewController, ImagesListViewProtocol {

    @IBOutlet weak var tableView: UITableView!

    private var presenter: ImagesListPresenterProtocol?

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		tableView.dataSource = self
		tableView.delegate = self
        presenter?.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		tableView.reloadData()
	}

    // MARK: - ImagesListViewProtocol
	func reloadRows(from oldCount: Int, to newCount: Int) {
        guard isViewLoaded else { return }
        guard newCount > oldCount else { return }

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        let currentRows = tableView.numberOfSections > 0 ? tableView.numberOfRows(inSection: 0) : 0
        guard currentRows == oldCount else {
            tableView.reloadData()
            return
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
	}

    func setLikeEnabled(_ enabled: Bool, at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.likeButton.isEnabled = enabled
        }
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
            if let url = presenter?.imageURLForDetails(at: indexPath) {
                viewController.imageURL = url
            } else if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
                viewController.image = cell.cellImage.image
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.cellHeight(for: tableView, at: indexPath) ?? 200
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        imageListCell.delegate = self
        presenter?.configureCell(imageListCell, at: indexPath)
        return imageListCell
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

