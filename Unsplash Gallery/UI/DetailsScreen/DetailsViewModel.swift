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

    init(startIndex: Int) {
        self.currentIndex = startIndex
        setupBindings()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        Publishers.CombineLatest(imageListService.$photos, $currentIndex)
            .map { photos, index in
                guard index >= 0, index < photos.count else { return nil }
                return photos[index]
            }
            .assign(to: \.currentPhoto, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func nextPhoto() {
        let photosCount = imageListService.photos.count
        
        if currentIndex >= photosCount - 2 {
            imageListService.fetchPhotosNextPage()
        }
        
        if currentIndex < photosCount - 1 {
            currentIndex += 1
        }
    }
    
    func prevPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    func toggleLike() {
        guard let photo = currentPhoto else { return }
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { _ in }
    }
}
