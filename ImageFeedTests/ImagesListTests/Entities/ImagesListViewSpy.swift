//
//  ImagesListViewSpy.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 10.01.26.
//
@testable import ImageFeed
import Foundation

final class ImagesListViewSpy: ImagesListViewProtocol {
    private(set) var reloadCalls: [(from: Int, to: Int)] = []
    private(set) var setLikeEnabledCalls: [(enabled: Bool, index: IndexPath)] = []
    private(set) var shownErrors: [String] = []
    var onSetLikeEnabled: ((Bool, IndexPath) -> Void)?

    func reloadRows(from oldCount: Int, to newCount: Int) {
        reloadCalls.append((oldCount, newCount))
    }

    func setLikeEnabled(_ enabled: Bool, at indexPath: IndexPath) {
        setLikeEnabledCalls.append((enabled, indexPath))
        onSetLikeEnabled?(enabled, indexPath)
    }

    func showError(message: String) {
        shownErrors.append(message)
    }
}
