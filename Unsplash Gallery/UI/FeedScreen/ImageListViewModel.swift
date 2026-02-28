//
//  ImageListViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//
typealias Photo = PhotoResult
import Foundation

final class ImageListViewModel {
    // MARK: - Properties

    private let imageListService = ImageListService.shared
    private var photos: [Photo] = []
    var mode: FeedMode = .feed

    var onChange: (() -> Void)?
    var onError: (() -> Void)?

    // MARK: - Public Data

    var photosCount: Int {
        photos.count
    }

    func photo(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }

    // MARK: - Actions

    func fetchPhotos() {
        imageListService.fethcLikedPhotosNextPage()
    }
    
    func setupObserver() {
            NotificationCenter.default.addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
        }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newPhotos = imageListService.photos
        self.photos = newPhotos
        
        onChange?()
    }
    
    func toggleLike(at index: Int) {
        let photo = photos[index]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) {_ in }
    }
}
