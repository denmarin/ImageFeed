//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 14.10.25.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    private var lastLoadURL: URL? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction private func buttonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let imageToShare = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            if let image { setImageAndFitByHeight(image) }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    private func loadFullImage(from url: URL) {
        lastLoadURL = url
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                let img = imageResult.image
                self.setImageAndFitByHeight(img)
            case .failure:
                self.showError()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageURL { loadFullImage(from: imageURL) }
        
        if imageURL == nil {
            if let image { setImageAndFitByHeight(image) }
        }
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
	private func showError() {
		let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Не надо", style: .cancel)
		let retry = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
			guard let self, let url = self.lastLoadURL ?? self.imageURL else { return }
			self.loadFullImage(from: url)
		}
		alert.addAction(cancel)
		alert.addAction(retry)
		present(alert, animated: true)
	}
    
    private func setImageAndFitByHeight(_ image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size

        view.layoutIfNeeded()

        let visibleSize = scrollView.bounds.size
        let imgSize = image.size
        let vScale = visibleSize.height / imgSize.height

        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        let scale = min(maxScale, max(minScale, vScale))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let contentSize = scrollView.contentSize
        let offsetX = max(0, (contentSize.width - visibleSize.width) / 2)
        let offsetY = max(0, (contentSize.height - visibleSize.height) / 2)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)

        let insetTop = max(0, (visibleSize.height - contentSize.height) / 2)
        let insetLeft = max(0, (visibleSize.width - contentSize.width) / 2)
        scrollView.contentInset = UIEdgeInsets(top: insetTop, left: insetLeft, bottom: insetTop, right: insetLeft)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let visible = scrollView.bounds.size
        let content = scrollView.contentSize
        let insetTop = max(0, (visible.height - content.height) / 2)
        let insetLeft = max(0, (visible.width - content.width) / 2)
        scrollView.contentInset = UIEdgeInsets(top: insetTop, left: insetLeft, bottom: insetTop, right: insetLeft)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let visible = scrollView.bounds.size
        let content = scrollView.contentSize
        let insetTop = max(0, (visible.height - content.height) / 2)
        let insetLeft = max(0, (visible.width - content.width) / 2)
        scrollView.contentInset = UIEdgeInsets(top: insetTop, left: insetLeft, bottom: insetTop, right: insetLeft)
    }
}
