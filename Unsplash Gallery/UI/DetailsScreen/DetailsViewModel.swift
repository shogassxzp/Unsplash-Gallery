//
//  DetailsViewModel.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 28.02.26.
//

import Foundation

final class DetailsViewModel {
    private let imageListService = ImageListService.shared
    private(set) var currentIndex: Int

    var onDataUpdated: (() -> Void)?
    
    init(startIndex: Int) {
        self.currentIndex = startIndex
    }
    
    var currentPhoto: PhotoResult? {
        guard currentIndex < imageListService.photos.count else {return nil}
        return imageListService.photos[currentIndex]
    }
    
    var authorName: String {
        currentPhoto?.user.name ?? "Unknown Author"
    }
    
    var description: String {
        currentPhoto?.description ?? "No description"
    }
    var formattedDate: String {
        currentPhoto?.createdAt?.toReadableDate() ?? "Date unknown"
    }
    
    var isLiked: Bool {
        currentPhoto?.likedByUser ?? false
    }
    
    func nextPhoto() {
        if currentIndex < imageListService.photos.count - 1 {
            currentIndex += 1
            onDataUpdated?()
        } else {
            imageListService.fethcLikedPhotosNextPage()
        }
    }
    func prevPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
            onDataUpdated?()
        }
    }
    
    func toggleLike(completion: @escaping (Bool) -> Void) {
        guard let photo = currentPhoto else {return}
        let newState = !photo.likedByUser
        imageListService.changeLike(photoId: photo.id, isLike: newState) { [weak self] result in
            switch result {
            case .success:
                completion(true)
            case.failure:
                completion(false)
            }
        }
    }
}
