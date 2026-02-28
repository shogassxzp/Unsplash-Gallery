//
//  DetailsViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Foundation
import Combine

final class DetailsViewModel {
    private let imageListService = ImageListService.shared
    private var cancellables = Set<AnyCancellable>()
    private let mode: FeedMode
    let transitionDirection = PassthroughSubject<Bool, Never>()
    
    // MARK: - Published Properties
    @Published private(set) var currentPhoto: PhotoResult?
    @Published private(set) var currentIndex: Int
    
    // MARK: - UI Properties
    var authorName: String { currentPhoto?.user.name ?? "Unknown Author" }
    var description: String { currentPhoto?.description ?? "No description" }
    var isLiked: Bool { currentPhoto?.likedByUser ?? false }
    var formattedDate: String {
        currentPhoto?.createdAt?.toReadableDate() ?? "Date unknown"
    }

    init(startIndex: Int, mode: FeedMode) {
        self.currentIndex = startIndex
        self.mode = mode
        setupBindings()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
            let sourcePublisher = (mode == .feed)
                ? imageListService.$photos
                : imageListService.$likedPhotos
            
            Publishers.CombineLatest(sourcePublisher, $currentIndex)
                .map { photos, index in
                    guard index >= 0, index < photos.count else { return nil }
                    return photos[index]
                }
                .assign(to: \.currentPhoto, on: self)
                .store(in: &cancellables)
        }
    
    // MARK: - Actions
    func nextPhoto() {
            let currentArray = (mode == .feed) ? imageListService.photos : imageListService.likedPhotos
            
            if currentIndex >= currentArray.count - 2 {
                mode == .feed ? imageListService.fetchPhotosNextPage() : imageListService.fethcLikedPhotosNextPage()
            }
            
            if currentIndex < currentArray.count - 1 {
                currentIndex += 1
                transitionDirection.send(true)
            }
        }
    
    func prevPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
            transitionDirection.send(false)
        }
    }
    
    func toggleLike() {
        guard let photo = currentPhoto else { return }
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { _ in }
    }
}
