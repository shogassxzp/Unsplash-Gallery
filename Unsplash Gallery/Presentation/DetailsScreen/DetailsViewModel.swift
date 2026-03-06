//
//  DetailsViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Combine
import Foundation

final class DetailsViewModel {
    // MARK: - Properties

    private let imageListService: ImageListService
    private var cancellables = Set<AnyCancellable>()
    private let mode: FeedMode

    let transitionDirection = PassthroughSubject<Bool, Never>()

    @Published private(set) var currentPhoto: PhotoResult?
    @Published private(set) var currentIndex: Int

    // MARK: - Computed Properties

    private var currentPhotosArray: [PhotoResult] {
        mode == .feed ? imageListService.photos : imageListService.likedPhotos
    }

    var authorName: String { currentPhoto?.user.name ?? "Unknown Author" }
    var description: String { currentPhoto?.description ?? "No description" }
    var isLiked: Bool { currentPhoto?.likedByUser ?? false }
    var formattedDate: String {
        currentPhoto?.createdAt?.toReadableDate() ?? "Date unknown"
    }

    // MARK: - Init

    init(startIndex: Int, mode: FeedMode, imageListService: ImageListService) {
        currentIndex = startIndex
        self.imageListService = imageListService
        self.mode = mode
        setupBindings()
    }
}

// MARK: - Navigation Logic

extension DetailsViewModel {
    func nextPhoto() {
        let photos = currentPhotosArray

        if currentIndex >= photos.count - 2 {
            fetchNextPage()
        }

        guard currentIndex < photos.count - 1 else { return }

        currentIndex += 1
        transitionDirection.send(true)
    }

    func prevPhoto() {
        guard currentIndex > 0 else { return }

        currentIndex -= 1
        transitionDirection.send(false)
    }

    private func fetchNextPage() {
        if mode == .feed {
            imageListService.fetchPhotosNextPage()
        } else {
            imageListService.fetchLikedPhotosNextPage()
        }
    }
}

// MARK: - Actions & Bindings

extension DetailsViewModel {
    func toggleLike() {
        guard let photo = currentPhoto else { return }

        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { result in
            if case let .failure(error) = result {
                print("Failed to toggle like: \(error)")
            }
        }
    }

    private func setupBindings() {
        let sourcePublisher = mode == .feed ? imageListService.$photos : imageListService.$likedPhotos

        Publishers.CombineLatest(sourcePublisher, $currentIndex)
            .map { photos, index -> PhotoResult? in
                guard photos.indices.contains(index) else { return nil }
                return photos[index]
            }
            .assign(to: &$currentPhoto)
    }
}
