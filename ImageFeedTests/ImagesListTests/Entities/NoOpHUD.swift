//
//  NoOpHUD.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 10.01.26.
//
@testable import ImageFeed
import Foundation

final class NoOpHUD: ProgressHUDProviding {
    func show() {}
    func dismiss() {}
}
