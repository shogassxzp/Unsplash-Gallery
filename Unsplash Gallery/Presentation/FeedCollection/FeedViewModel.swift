//
//  FeedViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Combine
import Foundation

final class FeedViewModel {
    private let imageListService = ImageListService.shared
    private var cancellables = Set<AnyCancellable>()

    var mode: FeedMode = .feed
    var onDataUpdated: (() -> Void)?

    var photosCount: Int {
        return mode == .feed ? imageListService.photos.count : imageListService.likedPhotos.count
    }

    func photo(at index: Int) -> PhotoResult? {
        let photos = mode == .feed ? imageListService.photos : imageListService.likedPhotos
        guard index < photos.count else { return nil }
        return photos[index]
    }

    func fetchNextPage() {
        if mode == .feed {
            imageListService.fetchPhotosNextPage()
        } else {
            imageListService.fetchLikedPhotosNextPage()
        }
    }

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        let photos = mode == .feed ? imageListService.photos : imageListService.likedPhotos
        guard index < photos.count else { return }
        let photo = photos[index]

        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { result in
            if case .success = result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    // MARK: - Combine Binding

    func setupObserver() {
        let publisher = (mode == .feed)
            ? imageListService.$photos
            : imageListService.$likedPhotos

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onDataUpdated?()
            }
            .store(in: &cancellables)
    }
}
