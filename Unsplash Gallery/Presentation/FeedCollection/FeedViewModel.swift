//
//  FeedViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Combine
import Foundation

final class FeedViewModel {
    // MARK: - Properties
    
    private let imageListService: ImageListService
    private var cancellables = Set<AnyCancellable>()
    
    var mode: FeedMode = .feed
    var onDataUpdated: (() -> Void)?

    // MARK: - Computed Properties
    
    private var currentPhotos: [PhotoResult] {
        mode == .feed ? imageListService.photos : imageListService.likedPhotos
    }

    var photosCount: Int {
        currentPhotos.count
    }

    // MARK: - Init
    
    init(imageListService: ImageListService) {
        self.imageListService = imageListService
    }
}

// MARK: - Data Access

extension FeedViewModel {
    func photo(at index: Int) -> PhotoResult? {
        guard currentPhotos.indices.contains(index) else { return nil }
        return currentPhotos[index]
    }
}

// MARK: - Network Logic

extension FeedViewModel {
    func fetchNextPage() {
        if mode == .feed {
            imageListService.fetchPhotosNextPage()
        } else {
            imageListService.fetchLikedPhotosNextPage()
        }
    }

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        let photos = currentPhotos
        guard photos.indices.contains(index) else {
            completion(false)
            return
        }
        
        let photo = photos[index]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { result in
            if case .success = result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

// MARK: - Combine Bindings

extension FeedViewModel {
    func setupObserver() {
        cancellables.removeAll()
        
        let publisher = mode == .feed ? imageListService.$photos : imageListService.$likedPhotos

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onDataUpdated?()
            }
            .store(in: &cancellables)
    }
}
