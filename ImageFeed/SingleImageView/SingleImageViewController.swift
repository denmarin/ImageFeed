//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 14.10.25.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    @IBAction private func buttonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImage.image = image
        }
    }
    
    @IBOutlet weak var singleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImage.image = image
    }
    
}
