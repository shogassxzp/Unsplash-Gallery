//
//  ImageListViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Foundation
import Combine

final class ImageListViewModel {
    // MARK: - Properties
    private let imageListService = ImageListService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var mode: FeedMode = .feed
    var onChange: (() -> Void)?
    
    // MARK: - Public Data
    
    private var currentSource: [PhotoResult] {
        mode == .feed ? imageListService.photos : imageListService.likedPhotos
    }
    
    var photosCount: Int {
        currentSource.count
    }
    
    func photo(at index: Int) -> PhotoResult? {
        guard index >= 0, index < currentSource.count else { return nil }
        return currentSource[index]
    }
    
    // MARK: - Actions
    
    func fetchNextPage() {
        if mode == .feed {
            imageListService.fetchPhotosNextPage()
        } else {
            imageListService.fethcLikedPhotosNextPage()
        }
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
