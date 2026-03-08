//
//  FavouriteViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 8.03.26.
//

import Foundation
import Combine

final class FavoritesViewModel: PhotoFeedViewModelProtocol {
    private let imageListService: ImageListService
    private var cancellables = Set<AnyCancellable>()

    var onDataUpdated: (() -> Void)? {
        didSet {
            if let onDataUpdated = onDataUpdated {
                onDataUpdated()
            }
        }
    }
    var photosCount: Int {
        return imageListService.likedPhotos.count
    }

    init(imageListService: ImageListService) {
        self.imageListService = imageListService
        setupSubscriptions()
    }

    func photo(at index: Int) -> PhotoResult? {
        guard imageListService.likedPhotos.indices.contains(index) else { return nil }
        return imageListService.likedPhotos[index]
    }

    func fetchNextPage() {
        imageListService.fetchLikedPhotosNextPage()
    }

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        guard imageListService.likedPhotos.indices.contains(index) else { return }
        let photo = imageListService.likedPhotos[index]

        imageListService.changeLike(photoId: photo.id, isLike: false) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: completion(true)
                case .failure: completion(false)
                }
            }
        }
    }

    private func setupSubscriptions() {
        imageListService.$likedPhotos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onDataUpdated?()
            }
            .store(in: &cancellables)
    }
}
