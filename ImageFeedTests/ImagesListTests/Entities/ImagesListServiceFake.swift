@testable import ImageFeed
import Foundation

final class ImagesListServiceFake: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchNextPageCalled = false
    var changeLikeCalls: [(id: String, isLike: Bool)] = []
    var changeLikeResult: Result<Bool, Error> = .success(true)

    func fetchPhotosNextPage() {
        fetchNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool) async throws -> Bool {
        changeLikeCalls.append((photoId, isLike))
        switch changeLikeResult {
        case .success(let value):
            if let idx = photos.firstIndex(where: { $0.id == photoId }) {
                photos[idx].isLiked = isLike
            }
            return value
        case .failure(let error):
            throw error
        }
    }
}
