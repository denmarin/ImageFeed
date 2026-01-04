//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.11.25.
//


import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
    
    static func show() {
        if RuntimeEnvironment.isUnitTesting { return }
        Task { @MainActor in
            window?.isUserInteractionEnabled = false
            ProgressHUD.animate()
        }
    }
    
    static func dismiss() {
        if RuntimeEnvironment.isUnitTesting { return }
        Task { @MainActor in
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }

}
