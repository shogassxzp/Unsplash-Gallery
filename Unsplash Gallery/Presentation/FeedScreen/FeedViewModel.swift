//
//  FeedViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Combine
import Foundation

final class FeedViewModel: PhotoFeedViewModelProtocol {
    private let imageListService: ImageListService
    private var cancellables = Set<AnyCancellable>()

    var onDataUpdated: (() -> Void)?
    var photosCount: Int { imageListService.photos.count }

    init(imageListService: ImageListService) {
        self.imageListService = imageListService
        setupSubscriptions()
    }

    func photo(at index: Int) -> PhotoResult? {
        guard imageListService.photos.indices.contains(index) else { return nil }
        return imageListService.photos[index]
    }

    func fetchNextPage() {
        imageListService.fetchPhotosNextPage()
    }

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        let photo = imageListService.photos[index]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { result in
            DispatchQueue.main.async {
                if case .success = result { completion(true) } else { completion(false) }
            }
        }
    }

    private func setupSubscriptions() {
        imageListService.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onDataUpdated?()
            }
            .store(in: &cancellables)
    }
}
