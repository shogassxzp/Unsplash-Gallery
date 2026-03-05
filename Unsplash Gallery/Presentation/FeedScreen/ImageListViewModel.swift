//
//  ImageListViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Combine
import Foundation

final class ImageListViewModel {
    // MARK: - Properties

    private let imageListService: ImageListService
    private var cancellables = Set<AnyCancellable>()

    var mode: FeedMode
    var onChange: (() -> Void)?

    init(imageListService: ImageListService, mode: FeedMode) {
        self.imageListService = imageListService
        self.mode = mode
    }

    // MARK: - Public Data

    private var currentSource: [PhotoResult] {
        mode == .feed ? imageListService.photos : imageListService.likedPhotos
    }

    var photosCount: Int {
        currentSource.count
    }

    func photo(at index: Int) -> PhotoResult? {
        guard currentSource.indices.contains(index) else { return nil }
        return currentSource[index]
    }

    // MARK: - Actions

    func fetchNextPage() {
        mode == .feed
        ? imageListService.fetchPhotosNextPage()
        : imageListService.fetchLikedPhotosNextPage()
    }

    func toggleLike(at index: Int) {
        guard let photo = photo(at: index) else { return }
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { _ in }
    }

    // MARK: - Combine Setup

    func setupObserver() {
        let publisher = (mode == .feed)
            ? imageListService.$photos
            : imageListService.$likedPhotos

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onChange?()
            }
            .store(in: &cancellables)
    }
}
