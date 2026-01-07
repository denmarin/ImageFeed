//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 27.10.25.
//

import UIKit
import WebKit



public protocol WebViewViewControllerProtocol: AnyObject {
	var presenter: WebViewPresenterProtocol? { get set }
	func load(request: URLRequest)
	func setProgressValue(_ newValue: Float)
	func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
	var presenter: WebViewPresenterProtocol?
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "WebViewViewController"
        webView.accessibilityIdentifier = "authWebView"
        progressView.accessibilityIdentifier = "authProgressView"
        webView.navigationDelegate = self
		presenter?.viewDidLoad()
        estimatedProgressObservation = webView.observe(\.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
            })
    }
	
	func load(request: URLRequest) {
		webView.load(request)
	}
    
	func setProgressValue(_ newValue: Float) {
		progressView.progress = newValue
	}

	func setProgressHidden(_ isHidden: Bool) {
		progressView.isHidden = isHidden
	}
    
    deinit {
        // Ensure observers and delegates are released to avoid crashes during teardown
        estimatedProgressObservation = nil
        webView?.navigationDelegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop any ongoing loads and release delegates/observers to avoid callbacks after teardown
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        estimatedProgressObservation = nil
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
	
	private func code(from navigationAction: WKNavigationAction) -> String? {
		if let url = navigationAction.request.url {
			return presenter?.code(from: url)
		}
		return nil
	}
}

