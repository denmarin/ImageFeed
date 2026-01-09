import Foundation

protocol ProgressHUDProviding {
    func show()
    func dismiss()
}

struct LiveProgressHUD: ProgressHUDProviding {
    func show() { UIBlockingProgressHUD.show() }
    func dismiss() { UIBlockingProgressHUD.dismiss() }
}
